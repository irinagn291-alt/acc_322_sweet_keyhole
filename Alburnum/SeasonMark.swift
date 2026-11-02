import Foundation

/// A committed sapwood ring. The amount is the ring size at the moment it moved into heartwood.
struct SeasonMark: Sendable, Equatable, Identifiable {
    var id: UUID
    var goalId: UUID
    var amount: Decimal
    var daykey: Int
}

/// Monthly season counts derived from SeasonMark daykeys. Not stored.
struct MonthSeasonCount: Sendable, Equatable, Identifiable {
    var year: Int
    var month: Int
    var count: Int

    var id: Int { year * 100 + month }
}

enum SeasonLedger {
    static func monthCounts(from marks: [SeasonMark]) -> [MonthSeasonCount] {
        var buckets: [Int: Int] = [:]
        for mark in marks {
            let key = Daykey.year(mark.daykey) * 100 + Daykey.month(mark.daykey)
            buckets[key, default: 0] += 1
        }
        return buckets.keys.sorted().map { key in
            MonthSeasonCount(year: key / 100, month: key % 100, count: buckets[key] ?? 0)
        }
    }
}
