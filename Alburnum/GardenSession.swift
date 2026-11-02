import SwiftUI

/// Main-actor state between the pith and the screens. It applies the fold, then asks the store to project it.
@MainActor
@Observable
final class GardenSession {
    private(set) var pith = Pith()
    private(set) var notice: String?
    private(set) var refusal: String?
    private(set) var onboardingComplete = false

    private var durable = Pith()
    private var generation = 0
    private var saveTask: Task<Void, Never>?
    private let store: ChartStore

    init(store: ChartStore) {
        self.store = store
    }

    var progress: Decimal { pith.progress }
    var wires: [Wire] { pith.wires }
    var phase: SapPhase { pith.phase }

    var phaseCaption: String {
        switch pith.phase {
        case .blank:
            return ""
        case .bare:
            return GardenCopy.ringClear
        case .wedged, .seasoned:
            return GardenCopy.ready
        case .ripe:
            return GardenCopy.ripe
        }
    }

    var analytics: AnalyticsBoard {
        AnalyticsBoard(seasons: pith.seasons)
    }

    var settings: SettingsBoard {
        SettingsBoard(
            currencyCode: pith.goal?.currencyCode ?? "USD",
            onboardingComplete: onboardingComplete,
            contactURL: GardenCopy.contactURL
        )
    }

    func open(seedDemo: Bool = true) async {
        let outcome = await store.load(seedDemo: seedDemo)
        pith = outcome.pith
        durable = outcome.pith
        notice = outcome.notice
        onboardingComplete = outcome.onboardingComplete
        refusal = nil
    }

    func wedge(amount: Decimal, daykey: Int) {
        let fold = pith.wedge(amount: amount, daykey: daykey)
        switch fold {
        case .appended(let next):
            adopt(next, refusal: nil)
        case .ripe(let next):
            adopt(next, refusal: GardenCopy.ripeWedge)
        case .ignored, .blank:
            break
        }
    }

    func season(daykey: Int) {
        switch pith.season(daykey: daykey) {
        case .committed(_, let settled):
            adopt(settled, refusal: nil)
        case .hollow(let next):
            adopt(next, refusal: GardenCopy.emptyRing)
        }
    }

    func peel() {
        let peeled = pith.peel()
        guard peeled.dropped != nil else { return }
        adopt(peeled.pith, refusal: nil)
    }

    func plant(name: String, target: Decimal, vineSeed: Int, currencyCode: String) {
        let next = pith.plant(name: name, target: target, vineSeed: vineSeed, currencyCode: currencyCode)
        guard next != pith else { return }
        adopt(next, refusal: nil)
    }

    func retint(currencyCode: String) {
        let next = pith.retint(currencyCode: currencyCode)
        guard next != pith else { return }
        adopt(next, refusal: nil)
    }

    func finishOnboarding() async {
        onboardingComplete = true
        await store.markOnboardingComplete()
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        generation += 1
        await persist(snapshot: pith, token: generation)
    }

    func resetAllData() async {
        saveTask?.cancel()
        saveTask = nil
        generation += 1
        let result = await store.resetAllData()
        switch result {
        case .stored:
            pith = Pith()
            durable = Pith()
            refusal = nil
            notice = nil
        case .failed(let message):
            notice = message
        }
    }

    func rerunOnboarding() async {
        onboardingComplete = false
        await store.clearOnboarding()
    }

    func noteScenePhase(_ phase: ScenePhase) async {
        if phase == .inactive || phase == .background {
            await flush()
        }
    }

    private func adopt(_ next: Pith, refusal: String?) {
        pith = next
        self.refusal = refusal
        scheduleSave()
    }

    private func scheduleSave() {
        generation += 1
        let token = generation
        let snapshot = pith
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(400))
            } catch {
                return
            }
            await self?.persist(snapshot: snapshot, token: token)
        }
    }

    private func persist(snapshot: Pith, token: Int) async {
        guard token == generation else { return }
        let result = await store.write(snapshot)
        guard token == generation else { return }
        switch result {
        case .stored:
            durable = snapshot
            if pith != snapshot {
                scheduleSave()
            }
        case .failed:
            if pith == snapshot {
                pith = durable
                notice = GardenCopy.unsaved
            }
        }
    }
}

/// Analytics sheet state derived from season marks. Empty, populated, and the load notice live apart from the chart file.
struct AnalyticsBoard: Sendable, Equatable {
    var months: [MonthSeasonCount]
    var commits: [SeasonMark]
    var isEmpty: Bool

    init(seasons: [SeasonMark]) {
        commits = seasons
        months = SeasonLedger.monthCounts(from: seasons)
        isEmpty = seasons.isEmpty
    }
}

/// Settings sheet state. The contact link and the onboarding flag are presentation, not a second store.
struct SettingsBoard: Sendable, Equatable {
    var currencyCode: String
    var onboardingComplete: Bool
    var contactURL: URL?
}
