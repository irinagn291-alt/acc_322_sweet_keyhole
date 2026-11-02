import XCTest
@testable import Alburnum

final class AlburnumTests: XCTestCase {
    func testProgressIsHeartwoodOverTargetAndIgnoresSap() {
        let pith = Pith.fieldCoatSeed()
        XCTAssertEqual(pith.heartwood.total, 80)
        XCTAssertEqual(pith.sapRing.total, 45)
        XCTAssertEqual(pith.progress, Decimal(80) / Decimal(240))
        XCTAssertEqual(Wire.quartiles, [
            Decimal(1) / Decimal(4),
            Decimal(1) / Decimal(2),
            Decimal(3) / Decimal(4),
            Decimal(1)
        ])
        XCTAssertTrue(pith.wires[0].reached)
        XCTAssertFalse(pith.wires[1].reached)
        XCTAssertFalse(pith.wires[2].reached)
        XCTAssertFalse(pith.wires[3].reached)
        XCTAssertEqual(pith.goal?.ringLobes, 3 + (17 % 5))
        let other = Pith().plant(name: "North bed", target: 100, vineSeed: 18, currencyCode: "USD")
        XCTAssertNotEqual(other.goal?.ringLobes, pith.goal?.ringLobes)
    }

    func testWedgeRejectsEmptyAndInvalidAmounts() {
        var pith = Pith().plant(name: "Coat", target: 100, vineSeed: 2, currencyCode: "USD")
        let ignored = pith.wedge(amount: 0, daykey: 20260101)
        XCTAssertEqual(ignored, .ignored(pith))
        XCTAssertTrue(pith.wedge(amount: -8, daykey: 20260101).pith.sapRing.wedges.isEmpty)
        pith = pith.wedge(amount: 12, daykey: 20260102).pith
        XCTAssertEqual(pith.phase, .wedged)
        XCTAssertEqual(pith.sapRing.total, 12)
        XCTAssertEqual(pith.heartwood.total, 0)
        XCTAssertTrue(pith.seasons.isEmpty)
    }

    func testSeasonTransfersRingThroughSeasonedThenBareOrRipe() {
        var pith = Pith().plant(name: "Coat", target: 100, vineSeed: 4, currencyCode: "USD")
        pith = pith.wedge(amount: 40, daykey: 20260201).pith
        let folded = pith.season(daykey: 20260202)
        guard case .committed(let moment, let settled) = folded else {
            return XCTFail("Expected a seasoned commit")
        }
        XCTAssertEqual(moment, .seasoned)
        XCTAssertEqual(settled.phase, .bare)
        XCTAssertEqual(settled.heartwood.total, 40)
        XCTAssertEqual(settled.sapRing.total, 0)
        XCTAssertEqual(settled.seasons.map(\.amount), [40])
        XCTAssertEqual(settled.progress, Decimal(40) / Decimal(100))

        var ripePath = settled.wedge(amount: 60, daykey: 20260203).pith
        let finish = ripePath.season(daykey: 20260204)
        guard case .committed(let ripeMoment, let ripe) = finish else {
            return XCTFail("Expected the ring to season into ripe")
        }
        XCTAssertEqual(ripeMoment, .seasoned)
        XCTAssertEqual(ripe.phase, .ripe)
        XCTAssertEqual(ripe.heartwood.total, 100)
        XCTAssertTrue(ripe.wires[3].reached)
        ripePath = ripe
        XCTAssertFalse(ripePath.seasonEnabled)
    }

    func testRefusedSeasonAndWedgeLeaveHeartwoodUntouched() {
        var bare = Pith().plant(name: "Coat", target: 50, vineSeed: 1, currencyCode: "USD")
        let hollow = bare.season(daykey: 20260301)
        guard case .hollow(let refused) = hollow else {
            return XCTFail("Season on a bare ring writes a hollow mark")
        }
        XCTAssertEqual(refused.hollows.count, 1)
        XCTAssertEqual(refused.heartwood.total, 0)
        XCTAssertEqual(refused.phase, .bare)
        XCTAssertTrue(refused.seasons.isEmpty)

        let unstaked = Pith().season(daykey: 20260302)
        guard case .hollow(let blank) = unstaked else {
            return XCTFail("An empty ring on a blank pith is refused")
        }
        XCTAssertEqual(blank.phase, .blank)
        XCTAssertEqual(blank.hollows.count, 1)

        bare = bare.wedge(amount: 50, daykey: 20260303).pith.season(daykey: 20260304).pith
        XCTAssertEqual(bare.phase, .ripe)
        let before = bare.heartwood.total
        let wedged = bare.wedge(amount: 9, daykey: 20260305)
        guard case .ripe(let refusedWedge) = wedged else {
            return XCTFail("Wedge on a ripe goal writes a ripe mark")
        }
        XCTAssertEqual(refusedWedge.ripes.map(\.amount), [9])
        XCTAssertEqual(refusedWedge.heartwood.total, before)
        XCTAssertTrue(refusedWedge.sapRing.wedges.isEmpty)
        XCTAssertEqual(refusedWedge.phase, .ripe)
    }

    func testPeelDropsOnlyTheLastWedge() {
        var pith = Pith().plant(name: "Coat", target: 80, vineSeed: 9, currencyCode: "EUR")
        pith = pith.wedge(amount: 10, daykey: 20260401).pith
        pith = pith.wedge(amount: 15, daykey: 20260402).pith
        let heartwood = pith.heartwood.total
        let peeled = pith.peel()
        XCTAssertEqual(peeled.dropped?.amount, 15)
        XCTAssertEqual(peeled.pith.sapRing.total, 10)
        XCTAssertEqual(peeled.pith.heartwood.total, heartwood)
        XCTAssertEqual(peeled.pith.phase, .wedged)
        let cleared = peeled.pith.peel()
        XCTAssertEqual(cleared.pith.phase, .bare)
        XCTAssertEqual(cleared.pith.heartwood.total, heartwood)
        let idle = cleared.pith.peel()
        XCTAssertNil(idle.dropped)
        XCTAssertEqual(idle.pith, cleared.pith)
    }

    func testFieldCoatSeedIsWedgedAndReadyToSeason() {
        let pith = Pith.fieldCoatSeed()
        XCTAssertEqual(pith.goal?.name, "Field coat")
        XCTAssertEqual(pith.goal?.target, 240)
        XCTAssertEqual(pith.goal?.vineSeed, 17)
        XCTAssertEqual(pith.goal?.currencyCode, "USD")
        XCTAssertEqual(pith.phase, .wedged)
        XCTAssertTrue(pith.seasonEnabled)
        XCTAssertLessThan(pith.progress, 1)
        XCTAssertEqual(pith.seasons.map(\.amount), [30, 50])
        XCTAssertEqual(pith.seasons.map(\.daykey), [20260312, 20260802])
        XCTAssertEqual(pith.sapRing.wedges.map(\.amount), [18, 27])
        let months = SeasonLedger.monthCounts(from: pith.seasons)
        XCTAssertEqual(months.map(\.count), [1, 1])
    }

    func testPersistenceRoundTripRestoresBackupAndResets() async throws {
        let harness = StoreHarness()
        let seeded = Pith.fieldCoatSeed()
        let first = await harness.store.write(seeded)
        XCTAssertEqual(first, .stored)

        let reloaded = await harness.store.load(seedDemo: false)
        XCTAssertNil(reloaded.notice)
        XCTAssertEqual(reloaded.pith, seeded)

        try FileManager.default.removeItem(at: harness.fileURL)
        let fromDefaults = await harness.store.load(seedDemo: false)
        XCTAssertEqual(fromDefaults.pith, seeded)

        let rewritten = await harness.store.write(seeded)
        XCTAssertEqual(rewritten, .stored)
        let peeled = seeded.peel().pith
        let peeledWrite = await harness.store.write(peeled)
        XCTAssertEqual(peeledWrite, .stored)
        let junk = Data("not-json".utf8)
        try junk.write(to: harness.fileURL, options: .atomic)
        let restored = await harness.store.load(seedDemo: false)
        XCTAssertEqual(restored.pith, seeded)
        XCTAssertNil(restored.notice)

        try junk.write(to: harness.fileURL, options: .atomic)
        try junk.write(to: harness.backupURL, options: .atomic)
        await harness.store.writeRaw(junk, forKey: ChartStore.storageKey)
        await harness.store.writeRaw(junk, forKey: ChartStore.backupKey)
        let blank = await harness.store.load(seedDemo: false)
        XCTAssertEqual(blank.pith.phase, .blank)
        XCTAssertEqual(blank.notice, GardenCopy.unreadable)

        let reset = await harness.store.resetAllData()
        XCTAssertEqual(reset, .stored)
        let stored = await harness.store.data(forKey: ChartStore.storageKey)
        let backup = await harness.store.data(forKey: ChartStore.backupKey)
        XCTAssertNil(stored)
        XCTAssertNil(backup)
        XCTAssertFalse(FileManager.default.fileExists(atPath: harness.fileURL.path))
    }

    func testSessionFlushSurvivesRelaunch() async {
        let harness = StoreHarness()
        let session = await GardenSession(store: harness.store)
        await session.open(seedDemo: false)
        await session.plant(name: "Field coat", target: 240, vineSeed: 17, currencyCode: "USD")
        await session.wedge(amount: 18, daykey: 20261025)
        await session.wedge(amount: 27, daykey: 20261025)
        await session.flush()
        let again = await GardenSession(store: harness.store)
        await again.open(seedDemo: false)
        let reloaded = await MainActor.run { again.pith }
        XCTAssertEqual(reloaded.phase, .wedged)
        XCTAssertEqual(reloaded.sapRing.total, 45)
        XCTAssertEqual(reloaded.goal?.name, "Field coat")
        let caption = await MainActor.run { again.phaseCaption }
        XCTAssertEqual(caption, GardenCopy.ready)
    }

    func testDaykeyUsesStartOfDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let components = DateComponents(year: 2026, month: 10, day: 25, hour: 23, minute: 30)
        let date = try XCTUnwrap(calendar.date(from: components))
        XCTAssertEqual(Daykey.make(from: date, calendar: calendar), 20261025)
    }

    func testRetintKeepsHeartwoodAndTheRing() {
        var pith = Pith.fieldCoatSeed()
        let heartwood = pith.heartwood.total
        let sap = pith.sapRing.total
        pith = pith.retint(currencyCode: "EUR")
        XCTAssertEqual(pith.goal?.currencyCode, "EUR")
        XCTAssertEqual(pith.heartwood.total, heartwood)
        XCTAssertEqual(pith.sapRing.total, sap)
        XCTAssertEqual(pith.phase, .wedged)
        XCTAssertTrue(pith.seasonEnabled)
        XCTAssertEqual(pith.retint(currencyCode: "EUR"), pith)
        XCTAssertEqual(pith.retint(currencyCode: " "), pith)
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "settings"]), "settings")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "currency"]), "currency")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "export"]), "export")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen", "ripe"]), "ripe")
        XCTAssertNil(ReviewLaunch.screen(in: ["Alburnum"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Alburnum", "-ReviewScreen"]))
    }
}

private final class StoreHarness {
    let directory: URL
    let store: ChartStore

    var fileURL: URL { directory.appendingPathComponent(ChartStore.fileName) }
    var backupURL: URL { directory.appendingPathComponent(ChartStore.backupName) }

    init() {
        let suite = "alburnum.tests." + UUID().uuidString
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(suite, isDirectory: true)
        store = ChartStore(directory: directory, suiteName: suite)
    }
}
