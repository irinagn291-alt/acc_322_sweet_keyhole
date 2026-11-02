import SwiftUI

/// Commit rows and a file share. The file is a copy. The garden stays on this phone.
struct ExportScreen: View {
    @Bindable var session: GardenSession
    var showsClose: Bool
    var onClose: () -> Void

    @State private var fileURL: URL?
    @State private var failed = false

    private var lines: [ExportLine] {
        ExportLine.make(from: session.pith)
    }

    var body: some View {
        ScrollView {
            if lines.isEmpty {
                empty
            } else {
                populated
            }
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .navigationTitle("Save a copy")
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
        .task(id: lines) {
            prepare()
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            if let latest = lines.last {
                Text(latest.title)
                    .font(TypeScale.face(.caption))
                    .foregroundStyle(DesignTokens.muted)
                Text(latest.amount, format: .currency(code: currency).precision(.fractionLength(0...2)))
                    .font(TypeScale.face(.display))
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if failed {
                Text("The file could not be saved. Try again.")
                    .font(TypeScale.face(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Retry") { prepare() }
                    .buttonStyle(CapsulePressStyle(role: .secondary))
            }
            ForEach(lines) { line in
                MaterialPlate {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
                        VStack(alignment: .leading, spacing: Spacing.s4) {
                            Text(line.title)
                                .font(TypeScale.face(.headline))
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(1)
                            dayText(line.daykey)
                        }
                        Spacer(minLength: Spacing.s8)
                        Text(line.amount, format: .currency(code: currency).precision(.fractionLength(0...2)))
                            .font(TypeScale.face(.headline))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                            .layoutPriority(1)
                    }
                }
            }
        }
        .padding(Spacing.s24)
        .safeAreaInset(edge: .bottom) {
            share
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, Spacing.s12)
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("Nothing to save yet. Season a ring first.")
                .font(TypeScale.face(.display))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.s24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            Button("Close", action: onClose)
                .buttonStyle(CapsulePressStyle())
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, Spacing.s12)
        }
    }

    @ViewBuilder
    private var share: some View {
        if let fileURL {
            ShareLink(item: fileURL) {
                Text("Save")
                    .font(TypeScale.face(.headline))
                    .foregroundStyle(DesignTokens.surface)
                    .frame(maxWidth: .infinity, minHeight: Metrics.hit)
                    .background(DesignTokens.accent, in: Capsule())
                    .contentShape(Capsule())
            }
        } else {
            Button("Save") {}
                .buttonStyle(CapsulePressStyle())
                .disabled(true)
        }
    }

    private var currency: String {
        let code = session.settings.currencyCode
        return code.isEmpty ? "USD" : code
    }

    private func prepare() {
        failed = false
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("alburnum-marks.csv")
        do {
            try ExportLine.csv(lines).write(to: url, atomically: true, encoding: .utf8)
            fileURL = url
        } catch {
            fileURL = nil
            failed = true
        }
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
}

struct ExportLine: Identifiable, Equatable, Hashable {
    var id: UUID
    var daykey: Int
    var title: String
    var amount: Decimal

    static func make(from pith: Pith) -> [ExportLine] {
        var rows: [ExportLine] = pith.seasons.map { mark in
            ExportLine(id: mark.id, daykey: mark.daykey, title: "Commit", amount: mark.amount)
        }
        rows += pith.sapRing.wedges.map { mark in
            ExportLine(id: mark.id, daykey: mark.daykey, title: "Waiting", amount: mark.amount)
        }
        return rows.sorted { lhs, rhs in
            if lhs.daykey == rhs.daykey { return lhs.title < rhs.title }
            return lhs.daykey < rhs.daykey
        }
    }

    static func csv(_ lines: [ExportLine]) -> String {
        var rows = ["date,kind,amount"]
        for line in lines {
            let amount = line.amount.formatted(
                .number.precision(.fractionLength(0...2)).grouping(.never).locale(Locale(identifier: "en_US_POSIX"))
            )
            rows.append("\(line.daykey),\(line.title),\(amount)")
        }
        return rows.joined(separator: "\n")
    }
}
