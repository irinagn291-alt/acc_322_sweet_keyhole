import SwiftUI

/// Currency, a copy of the marks, reset, contact, and onboarding again.
struct SettingsScreen: View {
    @Bindable var session: GardenSession
    var onClose: () -> Void
    var onRetry: () -> Void
    var onRerun: () -> Void

    @State private var confirmReset = false
    @State private var resetting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Text(session.settings.currencyCode.isEmpty ? "unknown" : session.settings.currencyCode)
                    .font(TypeScale.face(.display))
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Currency for this goal")
                    .font(TypeScale.face(.body))
                    .foregroundStyle(DesignTokens.ink)
                if let notice = session.notice {
                    Text(notice)
                        .font(TypeScale.face(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Retry", action: onRetry)
                        .buttonStyle(CapsulePressStyle(role: .secondary))
                }
                VStack(spacing: Spacing.s8) {
                    NavigationLink {
                        CurrencyScreen(session: session, showsClose: false, onClose: {})
                    } label: {
                        rowLabel(title: "Currency", symbol: "coloncurrencysign")
                    }
                    .buttonStyle(RowPressStyle())
                    NavigationLink {
                        ExportScreen(session: session, showsClose: false, onClose: {})
                    } label: {
                        rowLabel(title: "Save a copy", symbol: "square.and.arrow.up")
                    }
                    .buttonStyle(RowPressStyle())
                    Button {
                        confirmReset = true
                    } label: {
                        rowLabel(title: "Erase this garden", symbol: "trash")
                    }
                    .buttonStyle(RowPressStyle())
                    .disabled(resetting)
                    if let url = session.settings.contactURL {
                        Link(destination: url) {
                            rowLabel(title: "Contact", symbol: "envelope")
                        }
                    }
                    row(title: "Show the introduction again", symbol: "arrow.counterclockwise", action: onRerun)
                }
            }
            .padding(Spacing.s24)
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { close }
        .confirmationDialog("Erase this garden?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Erase", role: .destructive) {
                resetting = true
                Task {
                    await session.resetAllData()
                    resetting = false
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Goals and cash on this device will be deleted.")
        }
    }

    private func row(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowLabel(title: title, symbol: symbol)
        }
        .buttonStyle(RowPressStyle())
    }

    private func rowLabel(title: String, symbol: String) -> some View {
        HStack(spacing: Spacing.s12) {
            Image(systemName: symbol)
                .frame(width: Metrics.hit, height: Metrics.hit)
                .accessibilityHidden(true)
            Text(title)
                .font(TypeScale.face(.body))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .accessibilityHidden(true)
        }
        .padding(.horizontal, Spacing.s12)
        .frame(minHeight: Metrics.hit)
        .contentShape(Rectangle())
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Metrics.card, style: .continuous))
    }

    @ToolbarContentBuilder
    private var close: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onClose) {
                Label("Close", systemImage: "xmark")
                    .font(TypeScale.face(.body))
                    .frame(minHeight: Metrics.hit)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close")
        }
    }
}
