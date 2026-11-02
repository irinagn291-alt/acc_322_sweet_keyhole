import Foundation

/// Thickened trunk for one goal. The total moves only when a season transfers a positive sap ring.
struct Heartwood: Sendable, Equatable {
    var total: Decimal

    static let zero = Heartwood(total: 0)
}
