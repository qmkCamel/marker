import MarkerData
import MarkerDomain
import Foundation

@MainActor
struct MarkerAppDependencies {
    let supportedBoundaries: [MarkerDomainBoundary]
    let store: MarkerSQLiteStore

    static let live: MarkerAppDependencies = {
        let store = makeStore()

        return MarkerAppDependencies(
            supportedBoundaries: MarkerDataModule.supportedBoundaries,
            store: store ?? {
                fatalError("Unable to create MarkerSQLiteStore")
            }()
        )
    }()

    private static func makeStore() -> MarkerSQLiteStore? {
        if launchFlagEnabled("uitesting") {
            let store = try? MarkerSQLiteStore.inMemory()
            if launchFlagEnabled("seedDemoData"), let store {
                seedDemoData(into: store)
            }
            return store
        }

        return (try? MarkerSQLiteStore.live()) ?? (try? MarkerSQLiteStore.inMemory())
    }

    private static func launchFlagEnabled(_ name: String) -> Bool {
        let arguments = ProcessInfo.processInfo.arguments
        let defaults = UserDefaults.standard
        let kebabName = name.reduce(into: "") { result, character in
            if character.isUppercase {
                result.append("-")
                result.append(character.lowercased())
            } else {
                result.append(character)
            }
        }

        return arguments.contains("--\(name)") ||
            arguments.contains("--\(kebabName)") ||
            arguments.contains(name) ||
            arguments.contains(kebabName) ||
            defaults.bool(forKey: name)
    }

    private static func seedDemoData(into store: MarkerSQLiteStore) {
        do {
            let now = Date()
            let today = DayKey(date: now, timeZone: .current)
            let yesterday = today.addingDays(-1) ?? today
            let timeZoneIdentifier = TimeZone.current.identifier

            let waterTracker = Tracker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000101") ?? UUID(),
                kind: .habit,
                name: "喝水",
                colorToken: "blue",
                notes: "温和记录，不用追赶。",
                schedule: .daily,
                isArchived: false,
                createdAt: now.addingTimeInterval(-3_600),
                updatedAt: now.addingTimeInterval(-3_600)
            )
            let medicationTracker = Tracker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000102") ?? UUID(),
                kind: .medication,
                name: "晚间用药",
                colorToken: "green",
                notes: "睡前确认即可。",
                schedule: .daily,
                isArchived: false,
                createdAt: now.addingTimeInterval(-7_200),
                updatedAt: now.addingTimeInterval(-7_200)
            )
            let cycleTracker = Tracker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000103") ?? UUID(),
                kind: .cycle,
                name: "身体状态",
                colorToken: "pink",
                notes: "",
                schedule: .weeklyQuota(targetCount: 2),
                isArchived: false,
                createdAt: now.addingTimeInterval(-10_800),
                updatedAt: now.addingTimeInterval(-10_800)
            )

            try store.savePreferences(.defaultValue)
            try [waterTracker, medicationTracker, cycleTracker].forEach(store.saveTracker)
            try store.saveEntry(
                TrackingEntry(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000201") ?? UUID(),
                    trackerId: waterTracker.id,
                    dayKey: today,
                    recordedAt: now,
                    recordedTimeZoneIdentifier: timeZoneIdentifier,
                    payload: .completion(note: "早上已记录")
                )
            )
            try store.saveEntry(
                TrackingEntry(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000202") ?? UUID(),
                    trackerId: medicationTracker.id,
                    dayKey: yesterday,
                    recordedAt: now.addingTimeInterval(-86_400),
                    recordedTimeZoneIdentifier: timeZoneIdentifier,
                    payload: .medication(status: .taken, dose: 1, unit: "片", note: "饭后")
                )
            )
        } catch {
            assertionFailure("Unable to seed UI testing data: \(error)")
        }
    }
}
