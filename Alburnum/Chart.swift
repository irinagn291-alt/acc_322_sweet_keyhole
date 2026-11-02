import Foundation

/// One root record. The five storage slots are persistence names and never appear in the interface.
/// Islands are goals, books are season marks, sessions are the live sap ring, runs are heartwood totals, rhumbs are refusals.
struct Chart: Codable, Sendable, Equatable {
    var schemaVersion: Int
    var islands: [IslandSlot]
    var books: [BookSlot]
    var sessions: [SessionSlot]
    var runs: [RunSlot]
    var rhumbs: [RhumbSlot]

    static let currentSchema = 1

    init(
        schemaVersion: Int = Chart.currentSchema,
        islands: [IslandSlot] = [],
        books: [BookSlot] = [],
        sessions: [SessionSlot] = [],
        runs: [RunSlot] = [],
        rhumbs: [RhumbSlot] = []
    ) {
        self.schemaVersion = schemaVersion
        self.islands = islands
        self.books = books
        self.sessions = sessions
        self.runs = runs
        self.rhumbs = rhumbs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            islands = try container.decode([IslandSlot].self, forKey: .islands)
            books = try container.decode([BookSlot].self, forKey: .books)
            sessions = try container.decode([SessionSlot].self, forKey: .sessions)
            runs = try container.decode([RunSlot].self, forKey: .runs)
            rhumbs = try container.decode([RhumbSlot].self, forKey: .rhumbs)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported schemaVersion \(version)"
            )
        }
    }

    static let empty = Chart()
}

struct IslandSlot: Codable, Sendable, Equatable {
    var id: UUID
    var name: String
    var target: String
    var vineSeed: Int
    var currencyCode: String
}

struct BookSlot: Codable, Sendable, Equatable {
    var id: UUID
    var goalId: UUID
    var amount: String
    var daykey: Int
}

struct SessionSlot: Codable, Sendable, Equatable {
    var id: UUID
    var goalId: UUID
    var amount: String
    var daykey: Int
}

struct RunSlot: Codable, Sendable, Equatable {
    var goalId: UUID
    var total: String
}

struct RhumbSlot: Codable, Sendable, Equatable {
    var id: UUID
    var kind: String
    var daykey: Int
    var goalId: UUID?
    var amount: String?
}

enum ChartCodec {
    static func encode(_ chart: Chart) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(chart)
    }

    static func decode(_ data: Data) throws -> Chart {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(Chart.self, from: data)
    }
}

enum CashDecimal {
    static func encode(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }

    static func decode(_ raw: String) -> Decimal? {
        Decimal(string: raw, locale: Locale(identifier: "en_US_POSIX"))
    }
}

enum ChartMapping {
    static func chart(from pith: Pith) -> Chart {
        let islands = pith.planted.map { goal in
            IslandSlot(
                id: goal.id,
                name: goal.name,
                target: CashDecimal.encode(goal.target),
                vineSeed: goal.vineSeed,
                currencyCode: goal.currencyCode
            )
        }
        let books = pith.seasons.map { mark in
            BookSlot(
                id: mark.id,
                goalId: mark.goalId,
                amount: CashDecimal.encode(mark.amount),
                daykey: mark.daykey
            )
        }
        let sessions = pith.sapRing.wedges.map { mark in
            SessionSlot(
                id: mark.id,
                goalId: mark.goalId,
                amount: CashDecimal.encode(mark.amount),
                daykey: mark.daykey
            )
        }
        var runs: [RunSlot] = []
        for goal in pith.planted {
            runs.append(
                RunSlot(
                    goalId: goal.id,
                    total: CashDecimal.encode(pith.heartwood(for: goal.id).total)
                )
            )
        }
        var rhumbs: [RhumbSlot] = pith.hollows.map { mark in
            RhumbSlot(id: mark.id, kind: "hollow", daykey: mark.daykey, goalId: mark.goalId, amount: nil)
        }
        rhumbs.append(contentsOf: pith.ripes.map { mark in
            RhumbSlot(
                id: mark.id,
                kind: "ripe",
                daykey: mark.daykey,
                goalId: mark.goalId,
                amount: CashDecimal.encode(mark.amount)
            )
        })
        return Chart(
            islands: islands,
            books: books,
            sessions: sessions,
            runs: runs,
            rhumbs: rhumbs
        )
    }

    static func pith(from chart: Chart) -> Pith? {
        var planted: [Goal] = []
        for slot in chart.islands {
            guard let target = CashDecimal.decode(slot.target) else { return nil }
            planted.append(
                Goal(
                    id: slot.id,
                    name: slot.name,
                    target: target,
                    vineSeed: slot.vineSeed,
                    currencyCode: slot.currencyCode
                )
            )
        }
        var totals: [UUID: Decimal] = [:]
        for slot in chart.runs {
            guard let total = CashDecimal.decode(slot.total) else { return nil }
            totals[slot.goalId] = total
        }
        let liveId = planted.last?.id
        var wedges: [WedgeMark] = []
        for slot in chart.sessions where slot.goalId == liveId {
            guard let amount = CashDecimal.decode(slot.amount) else { return nil }
            wedges.append(
                WedgeMark(id: slot.id, goalId: slot.goalId, amount: amount, daykey: slot.daykey)
            )
        }
        var seasons: [SeasonMark] = []
        for slot in chart.books {
            guard let amount = CashDecimal.decode(slot.amount) else { return nil }
            seasons.append(
                SeasonMark(id: slot.id, goalId: slot.goalId, amount: amount, daykey: slot.daykey)
            )
        }
        var hollows: [HollowMark] = []
        var ripes: [RipeMark] = []
        for slot in chart.rhumbs {
            switch slot.kind {
            case "hollow":
                hollows.append(HollowMark(id: slot.id, goalId: slot.goalId, daykey: slot.daykey))
            case "ripe":
                guard let goalId = slot.goalId, let raw = slot.amount, let amount = CashDecimal.decode(raw) else {
                    return nil
                }
                ripes.append(RipeMark(id: slot.id, goalId: goalId, daykey: slot.daykey, amount: amount))
            default:
                return nil
            }
        }
        return Pith(
            planted: planted,
            totals: totals,
            sapRing: SapRing(wedges: wedges),
            seasons: seasons,
            hollows: hollows,
            ripes: ripes
        )
    }
}
