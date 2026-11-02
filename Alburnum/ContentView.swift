import SwiftUI
import UIKit

struct ContentView: View {
    @Bindable var session: GardenSession
    @Environment(\.scenePhase) private var scenePhase

    @State private var ready = false
    @State private var showSpinner = false
    @State private var stage: Stage = .garden
    @State private var cover: Cover?
    @State private var hookRead = false
    @State private var plantName = ""
    @State private var plantTarget = ""

    private enum Stage {
        case garden
        case ripe
    }

    private enum Cover: String, Identifiable {
        case log
        case plant
        case settings
        case currency
        case export

        var id: String { rawValue }
    }

    var body: some View {
        Group {
            if ready && !session.onboardingComplete {
                OnboardingScreen {
                    await session.finishOnboarding()
                    consumeHook()
                }
            } else {
                NavigationStack {
                    root
                        .navigationTitle(screenTitle)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { gardenTools }
                        .toolbarBackground(DesignTokens.bg, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
                .sheet(item: $cover) { item in
                    NavigationStack {
                        sheet(item)
                    }
                    .presentationCornerRadius(Metrics.card)
                    .presentationBackground(.regularMaterial)
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .tint(DesignTokens.accent)
        .preferredColorScheme(.light)
        .overlay {
            if showSpinner {
                ProgressView()
                    .tint(DesignTokens.accent)
                    .padding(Spacing.s16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Metrics.card, style: .continuous))
            }
        }
        .transaction { transaction in
            if !UIView.areAnimationsEnabled {
                transaction.disablesAnimations = true
            }
        }
        .task { await boot() }
        .onChange(of: scenePhase) { _, phase in
            guard ready else { return }
            Task { await session.noteScenePhase(phase) }
        }
    }

    @ViewBuilder
    private var root: some View {
        if stage == .ripe {
            RipeScreen {
                prefillPlant()
                cover = .plant
            }
        } else {
            GardenScreen(session: session, ready: ready, onPlant: openPlant, onRetry: retry)
        }
    }

    @ToolbarContentBuilder
    private var gardenTools: some ToolbarContent {
        if stage == .garden {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    cover = .log
                } label: {
                    Image(systemName: "chart.bar")
                        .frame(minWidth: Metrics.hit, minHeight: Metrics.hit)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Commits")
                Button {
                    cover = .settings
                } label: {
                    Image(systemName: "gearshape")
                        .frame(minWidth: Metrics.hit, minHeight: Metrics.hit)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Settings")
                Button(action: openPlant) {
                    Image(systemName: "leaf")
                        .frame(minWidth: Metrics.hit, minHeight: Metrics.hit)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Plant a goal")
            }
        }
    }

    private var screenTitle: String {
        session.pith.goal?.name ?? "Garden"
    }

    @ViewBuilder
    private func sheet(_ item: Cover) -> some View {
        switch item {
        case .log:
            AnalyticsScreen(session: session, onClose: { cover = nil }, onRetry: retry)
        case .plant:
            PlantScreen(
                session: session,
                name: $plantName,
                targetText: $plantTarget,
                onClose: { cover = nil },
                onRetry: retry
            )
        case .settings:
            SettingsScreen(session: session, onClose: { cover = nil }, onRetry: retry, onRerun: rerun)
        case .currency:
            CurrencyScreen(session: session, showsClose: true, onClose: { cover = nil })
        case .export:
            ExportScreen(session: session, showsClose: true, onClose: { cover = nil })
        }
    }

    private func openPlant() {
        prefillPlant()
        cover = .plant
    }

    private func prefillPlant() {
        plantName = session.pith.goal?.name ?? ""
        if let target = session.pith.goal?.target {
            plantTarget = CashField.fieldText(target)
        } else {
            plantTarget = ""
        }
    }

    private func retry() {
        Task { await session.open(seedDemo: true) }
    }

    private func rerun() {
        cover = nil
        Task { await session.rerunOnboarding() }
    }

    private func boot() async {
        let spinner = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            showSpinner = true
        }
        await session.open(seedDemo: true)
        spinner.cancel()
        showSpinner = false
        ready = true
        if session.onboardingComplete {
            consumeHook()
        }
    }

    private func consumeHook() {
        guard session.onboardingComplete, !hookRead else { return }
        hookRead = true
        switch ReviewLaunch.screen {
        case "log", "analytics":
            stage = .garden
            cover = .log
        case "goals", "plant":
            prefillPlant()
            stage = .garden
            cover = .plant
        case "settings":
            stage = .garden
            cover = .settings
        case "currency":
            stage = .garden
            cover = .currency
        case "export":
            stage = .garden
            cover = .export
        case "ripe":
            stage = .ripe
            cover = nil
        default:
            stage = .garden
            cover = nil
        }
    }
}

#Preview {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("alburnum-preview", isDirectory: true)
    ContentView(session: GardenSession(store: ChartStore(directory: directory, suiteName: "preview.alburnum")))
}
