import Foundation

/// Outer ring of uncommitted wedges. Its total is derived. Heartwood does not move while this ring fills.
struct SapRing: Sendable, Equatable {
    var wedges: [WedgeMark]

    var total: Decimal {
        wedges.reduce(0) { $0 + $1.amount }
    }

    var isEmpty: Bool {
        wedges.isEmpty || total <= 0
    }

    static let empty = SapRing(wedges: [])
}
