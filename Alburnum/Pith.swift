import Foundation

/// Sapwood fold over the wedges held in SapRing.
/// Phase is derived: no goal is Blank, heartwood at the target is Ripe, a positive ring is Wedged, otherwise Bare.
/// Seasoned exists only as the in-memory moment of a successful season, then the pith settles to Bare or Ripe.
struct Pith: Sendable, Equatable {
    var planted: [Goal]
    private var totals: [UUID: Decimal]
    var sapRing: SapRing
    var seasons: [SeasonMark]
    var hollows: [HollowMark]
    var ripes: [RipeMark]

    init(
        planted: [Goal] = [],
        totals: [UUID: Decimal] = [:],
        sapRing: SapRing = .empty,
        seasons: [SeasonMark] = [],
        hollows: [HollowMark] = [],
        ripes: [RipeMark] = []
    ) {
        self.planted = planted
        self.totals = totals
        self.sapRing = sapRing
        self.seasons = seasons
        self.hollows = hollows
        self.ripes = ripes
    }

    var goal: Goal? { planted.last }

    var heartwood: Heartwood {
        guard let goal else { return .zero }
        return Heartwood(total: totals[goal.id] ?? 0)
    }

    func heartwood(for goalId: UUID) -> Heartwood {
        Heartwood(total: totals[goalId] ?? 0)
    }

    var phase: SapPhase {
        guard let goal else { return .blank }
        if goal.target > 0, heartwood.total >= goal.target {
            return .ripe
        }
        if sapRing.total > 0 {
            return .wedged
        }
        return .bare
    }

    /// Progress is heartwood divided by the target. Cash still sitting in SapRing does not count.
    var progress: Decimal {
        guard let goal, goal.target > 0 else { return 0 }
        return heartwood.total / goal.target
    }

    var wires: [Wire] {
        Wire.marks(progress: progress)
    }

    var seasonEnabled: Bool {
        phase == .wedged && sapRing.total > 0
    }

    func wedge(amount: Decimal, daykey: Int) -> WedgeFold {
        guard amount > 0 else { return .ignored(self) }
        guard let goal else { return .blank(self) }
        if phase == .ripe {
            var next = self
            next.ripes.append(
                RipeMark(id: UUID(), goalId: goal.id, daykey: daykey, amount: amount)
            )
            return .ripe(next)
        }
        var next = self
        next.sapRing.wedges.append(
            WedgeMark(id: UUID(), goalId: goal.id, amount: amount, daykey: daykey)
        )
        return .appended(next)
    }

    func season(daykey: Int) -> SeasonFold {
        guard let goal else {
            return .hollow(recordingHollow(daykey: daykey, goalId: nil))
        }
        if sapRing.total <= 0 || phase == .bare || phase == .ripe {
            return .hollow(recordingHollow(daykey: daykey, goalId: goal.id))
        }
        let moved = sapRing.total
        var next = self
        next.seasons.append(
            SeasonMark(id: UUID(), goalId: goal.id, amount: moved, daykey: daykey)
        )
        let current = next.totals[goal.id] ?? 0
        next.totals[goal.id] = current + moved
        next.sapRing = .empty
        return .committed(moment: .seasoned, settled: next)
    }

    func peel() -> Peel {
        guard let dropped = sapRing.wedges.last else {
            return Peel(dropped: nil, pith: self)
        }
        var next = self
        next.sapRing.wedges.removeLast()
        return Peel(dropped: dropped, pith: next)
    }

    /// Plants a goal on a blank pith, or the next goal once the current one is ripe.
    func plant(name: String, target: Decimal, vineSeed: Int, currencyCode: String) -> Pith {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, target > 0 else { return self }
        guard phase == .blank || phase == .ripe else { return self }
        let code = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let goal = Goal(
            id: UUID(),
            name: trimmed,
            target: target,
            vineSeed: vineSeed,
            currencyCode: code.isEmpty ? "USD" : code
        )
        var next = self
        next.planted.append(goal)
        next.totals[goal.id] = next.totals[goal.id] ?? 0
        next.sapRing = .empty
        return next
    }

    /// Relabels the current goal. Heartwood, the ring, and the fold do not move.
    func retint(currencyCode: String) -> Pith {
        guard var current = goal else { return self }
        let code = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, code != current.currencyCode else { return self }
        current.currencyCode = code
        var next = self
        next.planted[next.planted.count - 1] = current
        return next
    }

    private func recordingHollow(daykey: Int, goalId: UUID?) -> Pith {
        var next = self
        next.hollows.append(HollowMark(id: UUID(), goalId: goalId, daykey: daykey))
        return next
    }
}

enum SapPhase: Sendable, Equatable {
    case blank
    case bare
    case wedged
    case seasoned
    case ripe
}

enum WedgeFold: Sendable, Equatable {
    case appended(Pith)
    case ignored(Pith)
    case ripe(Pith)
    case blank(Pith)

    var pith: Pith {
        switch self {
        case .appended(let pith), .ignored(let pith), .ripe(let pith), .blank(let pith):
            return pith
        }
    }
}

enum SeasonFold: Sendable, Equatable {
    /// `moment` is Seasoned. `settled` is the pith after the ring has moved, Bare or Ripe.
    case committed(moment: SapPhase, settled: Pith)
    case hollow(Pith)

    var pith: Pith {
        switch self {
        case .committed(_, let settled):
            return settled
        case .hollow(let pith):
            return pith
        }
    }
}

extension Pith {
    /// Simulator opening garden: heartwood 80, two wedges still in the ring, season ready.
    static func fieldCoatSeed() -> Pith {
        var pith = Pith().plant(name: "Field coat", target: 240, vineSeed: 17, currencyCode: "USD")
        pith = pith.wedge(amount: 30, daykey: 20260312).pith
        pith = pith.season(daykey: 20260312).pith
        pith = pith.wedge(amount: 50, daykey: 20260802).pith
        pith = pith.season(daykey: 20260802).pith
        pith = pith.wedge(amount: 18, daykey: 20261025).pith
        pith = pith.wedge(amount: 27, daykey: 20261025).pith
        return pith
    }
}
