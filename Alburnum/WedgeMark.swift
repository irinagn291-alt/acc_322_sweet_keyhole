import Foundation

/// One positive cash deposit held in the live sapwood ring. Append-only until Peel drops the latest mark.
struct WedgeMark: Sendable, Equatable, Identifiable {
    var id: UUID
    var goalId: UUID
    var amount: Decimal
    var daykey: Int
}
