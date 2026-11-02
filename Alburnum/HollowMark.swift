import Foundation

/// Refusal written when Season is asked of a bare pith or an empty sap ring. The ring does not move.
struct HollowMark: Sendable, Equatable, Identifiable {
    var id: UUID
    var goalId: UUID?
    var daykey: Int
}
