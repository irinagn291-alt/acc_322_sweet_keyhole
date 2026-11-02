import SwiftUI

/// Full-height local currency list. Choosing one relabels the goal and leaves the fold alone.
struct CurrencyScreen: View {
    @Bindable var session: GardenSession
    var showsClose: Bool
    var onClose: () -> Void

    private let codes = [
        "USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "SEK", "NOK", "DKK",
        "NZD", "PLN", "CZK", "HUF", "MXN", "BRL", "INR", "KRW", "SGD", "HKD"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Text(selectedName)
                    .font(TypeScale.face(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(session.settings.currencyCode)
                    .font(TypeScale.face(.title))
                    .foregroundStyle(DesignTokens.accent)
                if let notice = session.notice {
                    Text(notice)
                        .font(TypeScale.face(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                VStack(spacing: Spacing.s8) {
                    ForEach(codes, id: \.self) { code in
                        Button {
                            session.retint(currencyCode: code)
                        } label: {
                            HStack(spacing: Spacing.s12) {
                                VStack(alignment: .leading, spacing: Spacing.s4) {
                                    Text(name(for: code))
                                        .font(TypeScale.face(.body))
                                        .foregroundStyle(DesignTokens.ink)
                                        .lineLimit(1)
                                    Text(code)
                                        .font(TypeScale.face(.caption))
                                        .foregroundStyle(DesignTokens.muted)
                                }
                                Spacer(minLength: Spacing.s8)
                                if code == session.settings.currencyCode {
                                    Text("In use")
                                        .font(TypeScale.face(.micro))
                                        .foregroundStyle(DesignTokens.surface)
                                        .padding(.horizontal, Spacing.s8)
                                        .padding(.vertical, Spacing.s4)
                                        .background(DesignTokens.accent, in: RoundedRectangle(cornerRadius: Metrics.chip, style: .continuous))
                                }
                            }
                            .padding(.horizontal, Spacing.s12)
                            .frame(maxWidth: .infinity, minHeight: Metrics.hit, alignment: .leading)
                            .contentShape(Rectangle())
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Metrics.card, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(code == session.settings.currencyCode ? "\(name(for: code)), in use" : name(for: code))
                    }
                }
            }
            .padding(Spacing.s24)
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showsClose)
        .toolbar {
            if showsClose {
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
    }

    private var selectedName: String {
        name(for: session.settings.currencyCode)
    }

    private func name(for code: String) -> String {
        Locale.current.localizedString(forCurrencyCode: code) ?? "unknown"
    }
}
