import SwiftUI

/// Decimal entry for hand-typed cash. Rejects signs and letters before they reach the fold.
enum CashField {
    static let dragCeiling: CGFloat = 2400

    static func sanitize(_ raw: String) -> String {
        let separator = Locale.current.decimalSeparator ?? "."
        var output = ""
        var usedSeparator = false
        for character in raw {
            if character.isNumber {
                output.append(character)
            } else if String(character) == separator, !usedSeparator {
                usedSeparator = true
                output.append(character)
            }
        }
        return output
    }

    static func parse(_ raw: String) -> Decimal? {
        let cleaned = sanitize(raw)
        guard !cleaned.isEmpty else { return nil }
        guard let value = Decimal(string: cleaned, locale: .current), value > 0 else { return nil }
        return value
    }

    static func dragAmount(_ points: CGFloat) -> Decimal {
        guard points > 0 else { return 0 }
        let clamped = min(points, dragCeiling)
        return Decimal(Double(clamped))
    }

    static func fieldText(_ value: Decimal) -> String {
        sanitize(value.formatted(.number.precision(.fractionLength(0...2))))
    }
}

enum DayStamp {
    static func date(from daykey: Int, calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = Daykey.year(daykey)
        parts.month = Daykey.month(daykey)
        parts.day = daykey % 100
        parts.calendar = calendar
        return calendar.date(from: parts)
    }
}

struct Hairline: View {
    var body: some View {
        Rectangle()
            .fill(DesignTokens.muted.opacity(0.45))
            .frame(height: Metrics.hairline)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

struct MaterialPlate<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Spacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Metrics.card, style: .continuous))
    }
}
