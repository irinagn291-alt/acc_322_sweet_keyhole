import Foundation

/// Result of dropping the latest wedge. A nil drop means SapRing was already empty and nothing was appended.
struct Peel: Sendable, Equatable {
    var dropped: WedgeMark?
    var pith: Pith
}
