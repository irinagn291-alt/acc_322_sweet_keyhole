import Foundation

/// Calendar day stamp for every mark. The fold stores the integer, never a computed total.
enum Daykey {
    static func make(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func year(_ daykey: Int) -> Int {
        daykey / 10_000
    }

    static func month(_ daykey: Int) -> Int {
        (daykey / 100) % 100
    }
}
