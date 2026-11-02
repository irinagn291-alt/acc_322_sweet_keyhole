import Foundation

/// Named saving target planted on the pith. vineSeed drives the sapwood ring shape and is not a stored drawing.
struct Goal: Sendable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var target: Decimal
    var vineSeed: Int
    var currencyCode: String

    /// Lobe count of the ring. Two seeds that differ in this residue draw different rings.
    var ringLobes: Int {
        3 + (abs(vineSeed) % 5)
    }
}
