import Foundation

/// Quartile markers on the path from heartwood to the goal target. Positions are derived from progress.
struct Wire: Sendable, Equatable, Identifiable {
    var fraction: Decimal
    var reached: Bool

    var id: Decimal { fraction }

    static let quartiles: [Decimal] = [
        Decimal(1) / Decimal(4),
        Decimal(1) / Decimal(2),
        Decimal(3) / Decimal(4),
        Decimal(1)
    ]

    static func marks(progress: Decimal) -> [Wire] {
        quartiles.map { fraction in
            Wire(fraction: fraction, reached: progress >= fraction)
        }
    }
}
