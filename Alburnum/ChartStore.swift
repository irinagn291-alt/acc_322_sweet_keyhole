import Foundation

/// Seam between the pith and disk. Views never touch this type. The in-memory chart is applied by the caller.
actor ChartStore {
    static let storageKey = "alb.chart.v1"
    static let backupKey = "alb.chart.v1.bak"
    static let demoKey = "alb.demo.v1"
    static let onboardingKey = "alb.onboarded.v1"
    static let fileName = "alb.chart.v1.json"
    static let backupName = "alb.chart.v1.bak"

    private let directory: URL
    private let defaults: UserDefaults

    init(directory: URL, defaults: UserDefaults = .standard) {
        self.directory = directory
        self.defaults = defaults
    }

    init(directory: URL, suiteName: String) {
        self.directory = directory
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        self.defaults = defaults
    }

    static func applicationSupportDirectory() throws -> URL {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw ChartStoreError.directoryUnavailable
        }
        return base.appendingPathComponent("Sweet Keyhole", isDirectory: true)
    }

    func load(seedDemo: Bool) async -> LoadOutcome {
        do {
            try prepareDirectory()
        } catch {
            return LoadOutcome(
                pith: Pith(),
                notice: GardenCopy.unreadable,
                onboardingComplete: defaults.bool(forKey: Self.onboardingKey)
            )
        }

        if let chart = firstReadableChart() {
            if let pith = ChartMapping.pith(from: chart) {
                return LoadOutcome(
                    pith: pith,
                    notice: nil,
                    onboardingComplete: defaults.bool(forKey: Self.onboardingKey)
                )
            }
        }

        let hadBytes = primaryData() != nil
            || backupData() != nil
            || defaults.data(forKey: Self.storageKey) != nil
            || defaults.data(forKey: Self.backupKey) != nil

        if !hadBytes, seedDemo, applySimulatorSeedIfNeeded() {
            if let chart = firstReadableChart(), let pith = ChartMapping.pith(from: chart) {
                return LoadOutcome(pith: pith, notice: nil, onboardingComplete: true)
            }
        }

        if hadBytes {
            return LoadOutcome(
                pith: Pith(),
                notice: GardenCopy.unreadable,
                onboardingComplete: defaults.bool(forKey: Self.onboardingKey)
            )
        }

        return LoadOutcome(
            pith: Pith(),
            notice: nil,
            onboardingComplete: defaults.bool(forKey: Self.onboardingKey)
        )
    }

    func write(_ pith: Pith) async -> StoreWrite {
        let chart = ChartMapping.chart(from: pith)
        let data: Data
        do {
            data = try ChartCodec.encode(chart)
        } catch {
            return .failed(error.localizedDescription)
        }
        do {
            try prepareDirectory()
            try archivePrimary()
            try data.write(to: primaryURL, options: .atomic)
            defaults.set(data, forKey: Self.storageKey)
            return .stored
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func resetAllData() async -> StoreWrite {
        do {
            try prepareDirectory()
            if FileManager.default.fileExists(atPath: primaryURL.path) {
                try FileManager.default.removeItem(at: primaryURL)
            }
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            defaults.removeObject(forKey: Self.storageKey)
            defaults.removeObject(forKey: Self.backupKey)
            return .stored
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func markOnboardingComplete() {
        defaults.set(true, forKey: Self.onboardingKey)
    }

    func clearOnboarding() {
        defaults.set(false, forKey: Self.onboardingKey)
    }

    func writeRaw(_ data: Data, forKey key: String) {
        defaults.set(data, forKey: key)
    }

    func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    private var primaryURL: URL {
        directory.appendingPathComponent(Self.fileName)
    }

    private var backupURL: URL {
        directory.appendingPathComponent(Self.backupName)
    }

    private func prepareDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func archivePrimary() throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: primaryURL.path) {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            try fileManager.copyItem(at: primaryURL, to: backupURL)
        }
        if let current = defaults.data(forKey: Self.storageKey) {
            defaults.set(current, forKey: Self.backupKey)
        }
    }

    private func firstReadableChart() -> Chart? {
        let sources = [
            primaryData(),
            backupData(),
            defaults.data(forKey: Self.storageKey),
            defaults.data(forKey: Self.backupKey)
        ]
        for source in sources {
            guard let source else { continue }
            do {
                return try ChartCodec.decode(source)
            } catch {
                continue
            }
        }
        return nil
    }

    private func primaryData() -> Data? {
        readFile(at: primaryURL)
    }

    private func backupData() -> Data? {
        readFile(at: backupURL)
    }

    private func readFile(at url: URL) -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    private func applySimulatorSeedIfNeeded() -> Bool {
        #if targetEnvironment(simulator)
        if defaults.bool(forKey: Self.demoKey) {
            return false
        }
        let seeded = Pith.fieldCoatSeed()
        switch writeSync(seeded) {
        case .stored:
            defaults.set(true, forKey: Self.demoKey)
            defaults.set(true, forKey: Self.onboardingKey)
            return true
        case .failed:
            return false
        }
        #else
        return false
        #endif
    }

    private func writeSync(_ pith: Pith) -> StoreWrite {
        let chart = ChartMapping.chart(from: pith)
        do {
            let data = try ChartCodec.encode(chart)
            try prepareDirectory()
            try archivePrimary()
            try data.write(to: primaryURL, options: .atomic)
            defaults.set(data, forKey: Self.storageKey)
            return .stored
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}

struct LoadOutcome: Sendable, Equatable {
    var pith: Pith
    var notice: String?
    var onboardingComplete: Bool
}

enum StoreWrite: Sendable, Equatable {
    case stored
    case failed(String)
}

enum ChartStoreError: Error {
    case directoryUnavailable
}

enum GardenCopy {
    static let unreadable = "The saved garden could not be read. A fresh garden is ready."
    static let unsaved = "The garden could not be saved. The last saved ring is showing."
    static let emptyRing = "The ring is empty. Wedge cash, then season the ring."
    static let ripeWedge = "This goal is ripe. Plant a new goal."
    static let ringClear = "Ring is clear"
    static let ready = "Ready to season"
    static let ripe = "This goal is ripe"
    static let contactURL = URL(string: "https://alburnum-pith.space/contact-us")
}
