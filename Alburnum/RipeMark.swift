import Foundation

/// Refusal written when Wedge is asked of a ripe goal. The amount is the cash that was not appended.
struct RipeMark: Sendable, Equatable, Identifiable {
    var id: UUID
    var goalId: UUID
    var daykey: Int
    var amount: Decimal
}
