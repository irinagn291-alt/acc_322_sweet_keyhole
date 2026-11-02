import Charts
import SwiftUI

/// Monthly commits and the outer-band size at each season. Stock charts only.
struct AnalyticsScreen: View {
    @Bindable var session: GardenSession
    var onClose: () -> Void
    var onRetry: () -> Void

    var body: some View {
        ScrollView {
            if session.analytics.isEmpty {
                empty
            } else {
                populated
            }
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .navigationTitle("Commits")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { close }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            if let notice = session.notice {
                noticeBlock(notice)
            }
            MaterialPlate {
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    Text("Latest commit")
                        .font(TypeScale.face(.caption))
                        .foregroundStyle(DesignTokens.muted)
                    if let latest = session.analytics.commits.last {
                        Text(latest.amount, format: .currency(code: currency).precision(.fractionLength(0...2)))
                            .font(TypeScale.face(.display))
                            .foregroundStyle(DesignTokens.accent)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)
                        dayText(latest.daykey)
                    }
                    Text("Outer band at each commit")
                        .font(TypeScale.face(.caption))
                        .foregroundStyle(DesignTokens.ink)
                    Charts.Chart(session.analytics.months) { month in
                        BarMark(
                            x: .value("Month", monthDate(month), unit: .month),
                            y: .value("Count", month.count)
                        )
                        .foregroundStyle(DesignTokens.accent)
                    }
                    .frame(height: Spacing.s48 * 3)
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let count = value.as(Double.self) {
                                    Text(count, format: .number.precision(.fractionLength(0)))
                                        .font(TypeScale.face(.micro))
                                }
                            }
                        }
                    }
                    .accessibilityLabel("Commits by month")
                }
            }
            VStack(spacing: Spacing.s8) {
                ForEach(session.analytics.commits) { mark in
                    MaterialPlate {
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
                            VStack(alignment: .leading, spacing: Spacing.s4) {
                                Text("Commit")
                                    .font(TypeScale.face(.headline))
                                    .foregroundStyle(DesignTokens.ink)
                                    .lineLimit(1)
                                dayText(mark.daykey)
                            }
                            Spacer(minLength: Spacing.s8)
                            Text(mark.amount, format: .currency(code: currency).precision(.fractionLength(0...2)))
                                .font(TypeScale.face(.headline))
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(1)
                                .layoutPriority(1)
                        }
                    }
                }
            }
        }
        .padding(Spacing.s24)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            if let notice = session.notice {
                noticeBlock(notice)
            }
            Text("No seasons yet")
                .font(TypeScale.face(.display))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Commit a ring on Garden to see it here.")
                .font(TypeScale.face(.body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.s24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            Button("Season", action: onClose)
                .buttonStyle(CapsulePressStyle())
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, Spacing.s12)
        }
    }

    private func noticeBlock(_ notice: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(notice)
                .font(TypeScale.face(.body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry", action: onRetry)
                .buttonStyle(CapsulePressStyle(role: .secondary))
        }
    }

    private var currency: String {
        let code = session.settings.currencyCode
        return code.isEmpty ? "USD" : code
    }

    private func monthDate(_ month: MonthSeasonCount) -> Date {
        DayStamp.date(from: month.year * 10_000 + month.month * 100 + 1) ?? .now
    }

    @ViewBuilder
    private func dayText(_ daykey: Int) -> some View {
        if let date = DayStamp.date(from: daykey) {
            Text(date, format: .dateTime.month(.abbreviated).day().year())
                .font(TypeScale.face(.caption))
                .foregroundStyle(DesignTokens.muted)
        } else {
            Text("unknown")
                .font(TypeScale.face(.caption))
                .foregroundStyle(DesignTokens.muted)
        }
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
