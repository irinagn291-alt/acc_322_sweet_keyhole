import SwiftUI

/// Names the next goal and its target. Save is refused while the current goal is still open.
struct PlantScreen: View {
    @Bindable var session: GardenSession
    @Binding var name: String
    @Binding var targetText: String
    var onClose: () -> Void
    var onRetry: () -> Void

    @FocusState private var focus: Field?

    private enum Field: Hashable {
        case name
        case target
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Text(displayName)
                    .font(TypeScale.face(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let notice = session.notice {
                    Text(notice)
                        .font(TypeScale.face(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Retry", action: onRetry)
                        .buttonStyle(CapsulePressStyle(role: .secondary))
                }
                if !canPlant {
                    Text("This goal is still open. Season the waiting cash before planting another.")
                        .font(TypeScale.face(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                MaterialPlate {
                    VStack(alignment: .leading, spacing: Spacing.s12) {
                        Text("Name")
                            .font(TypeScale.face(.caption))
                            .foregroundStyle(DesignTokens.muted)
                        TextField("Name", text: $name)
                            .font(TypeScale.face(.body))
                            .focused($focus, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focus = .target }
                            .frame(minHeight: Metrics.hit)
                        Text("Target")
                            .font(TypeScale.face(.caption))
                            .foregroundStyle(DesignTokens.muted)
                        TextField("Target", text: $targetText)
                            .font(TypeScale.face(.body))
                            .keyboardType(.decimalPad)
                            .focused($focus, equals: .target)
                            .frame(minHeight: Metrics.hit)
                            .onChange(of: targetText) { _, newValue in
                                let cleaned = CashField.sanitize(newValue)
                                if cleaned != newValue {
                                    targetText = cleaned
                                }
                            }
                        if !targetText.isEmpty && CashField.parse(targetText) == nil {
                            Text("Enter a number greater than zero.")
                                .font(TypeScale.face(.caption))
                                .foregroundStyle(DesignTokens.ink)
                        }
                    }
                }
            }
            .padding(Spacing.s24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DesignTokens.bg.ignoresSafeArea())
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onClose) {
                    Label("Close", systemImage: "xmark")
                        .font(TypeScale.face(.body))
                        .frame(minHeight: Metrics.hit)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Close")
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
                    .frame(minHeight: Metrics.hit)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save", action: save)
                .buttonStyle(CapsulePressStyle())
                .disabled(!canSave)
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, Spacing.s12)
        }
        .simultaneousGesture(TapGesture().onEnded { focus = nil })
    }

    private var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Name the goal" : trimmed
    }

    private var canPlant: Bool {
        session.pith.phase == .blank || session.pith.phase == .ripe
    }

    private var canSave: Bool {
        canPlant
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && CashField.parse(targetText) != nil
    }

    private func save() {
        guard canSave, let target = CashField.parse(targetText) else { return }
        let seed = name.unicodeScalars.reduce(0) { partial, scalar in
            partial &+ Int(scalar.value)
        }
        session.plant(
            name: name,
            target: target,
            vineSeed: seed,
            currencyCode: session.settings.currencyCode
        )
        onClose()
    }
}
