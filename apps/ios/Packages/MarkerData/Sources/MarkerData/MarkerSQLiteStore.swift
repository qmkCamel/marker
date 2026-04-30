import Foundation
import GRDB
import MarkerDomain

public final class MarkerSQLiteStore {
    private let databaseQueue: DatabaseQueue

    public init(path: String) throws {
        databaseQueue = try DatabaseQueue(path: path)
        try Self.migrator.migrate(databaseQueue)
    }

    private init(databaseQueue: DatabaseQueue) throws {
        self.databaseQueue = databaseQueue
        try Self.migrator.migrate(databaseQueue)
    }

    public static func inMemory() throws -> MarkerSQLiteStore {
        try MarkerSQLiteStore(databaseQueue: DatabaseQueue())
    }

    public static func live(fileManager: FileManager = .default) throws -> MarkerSQLiteStore {
        let baseURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = baseURL.appendingPathComponent("Marker", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        return try MarkerSQLiteStore(path: directoryURL.appendingPathComponent("marker.sqlite").path)
    }

    public func fetchAllTrackers() throws -> [Tracker] {
        try databaseQueue.read { db in
            try TrackerRecord
                .order(Column("isArchived"), Column("createdAt"))
                .fetchAll(db)
                .map(\.domainModel)
        }
    }

    public func fetchActiveTrackers() throws -> [Tracker] {
        try databaseQueue.read { db in
            try TrackerRecord
                .filter(Column("isArchived") == false)
                .order(Column("createdAt"))
                .fetchAll(db)
                .map(\.domainModel)
        }
    }

    public func fetchArchivedTrackers() throws -> [Tracker] {
        try databaseQueue.read { db in
            try TrackerRecord
                .filter(Column("isArchived") == true)
                .order(Column("updatedAt").desc)
                .fetchAll(db)
                .map(\.domainModel)
        }
    }

    public func saveTracker(_ tracker: Tracker) throws {
        try databaseQueue.write { db in
            try TrackerRecord(tracker).save(db)
        }
    }

    public func fetchAllEntries() throws -> [TrackingEntry] {
        try databaseQueue.read { db in
            try TrackingEntryRecord
                .order(Column("dayKey").desc, Column("recordedAt").desc)
                .fetchAll(db)
                .map(\.domainModel)
        }
    }

    public func fetchEntries(on dayKey: DayKey) throws -> [TrackingEntry] {
        try databaseQueue.read { db in
            try TrackingEntryRecord
                .filter(Column("dayKey") == dayKey.rawValue)
                .order(Column("recordedAt").desc)
                .fetchAll(db)
                .map(\.domainModel)
        }
    }

    public func fetchEntries(from start: DayKey, through end: DayKey) throws -> [TrackingEntry] {
        try databaseQueue.read { db in
            try TrackingEntryRecord
                .filter(Column("dayKey") >= start.rawValue && Column("dayKey") <= end.rawValue)
                .order(Column("dayKey").desc, Column("recordedAt").desc)
                .fetchAll(db)
                .map(\.domainModel)
        }
    }

    public func fetchEntry(trackerId: UUID, dayKey: DayKey) throws -> TrackingEntry? {
        try databaseQueue.read { db in
            try TrackingEntryRecord
                .filter(Column("trackerId") == trackerId.uuidString && Column("dayKey") == dayKey.rawValue)
                .fetchOne(db)?
                .domainModel
        }
    }

    public func saveEntry(_ entry: TrackingEntry) throws {
        try databaseQueue.write { db in
            if let existing = try TrackingEntryRecord
                .filter(Column("trackerId") == entry.trackerId.uuidString && Column("dayKey") == entry.dayKey.rawValue)
                .fetchOne(db) {
                var updated = TrackingEntryRecord(entry)
                updated.id = existing.id
                try updated.update(db)
            } else {
                try TrackingEntryRecord(entry).insert(db)
            }
        }
    }

    public func deleteEntry(trackerId: UUID, dayKey: DayKey) throws {
        try databaseQueue.write { db in
            _ = try TrackingEntryRecord
                .filter(Column("trackerId") == trackerId.uuidString && Column("dayKey") == dayKey.rawValue)
                .deleteAll(db)
        }
    }

    public func fetchWeeklyEntryCount(
        trackerId: UUID,
        for dayKey: DayKey,
        weekStartsOn: MarkerWeekday
    ) throws -> Int {
        guard let bounds = Self.weekBounds(containing: dayKey, weekStartsOn: weekStartsOn) else {
            return 0
        }

        return try databaseQueue.read { db in
            try TrackingEntryRecord
                .filter(
                    Column("trackerId") == trackerId.uuidString &&
                    Column("dayKey") >= bounds.start.rawValue &&
                    Column("dayKey") <= bounds.end.rawValue
                )
                .fetchCount(db)
        }
    }

    public func fetchPreferences() throws -> UserPreference? {
        try databaseQueue.read { db in
            try UserPreferenceRecord.fetchOne(db)?.domainModel
        }
    }

    public func savePreferences(_ preferences: UserPreference) throws {
        try databaseQueue.write { db in
            try UserPreferenceRecord(preferences).save(db)
        }
    }

    private static let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_local_tracking") { db in
            try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS trackers (
                id TEXT PRIMARY KEY,
                kind TEXT NOT NULL,
                name TEXT NOT NULL,
                colorToken TEXT NOT NULL,
                notes TEXT NOT NULL,
                scheduleType TEXT NOT NULL,
                scheduleWeekdays TEXT,
                scheduleTargetCount INTEGER,
                isArchived INTEGER NOT NULL,
                createdAt DOUBLE NOT NULL,
                updatedAt DOUBLE NOT NULL
            );

            CREATE TABLE IF NOT EXISTS trackingEntries (
                id TEXT PRIMARY KEY,
                trackerId TEXT NOT NULL REFERENCES trackers(id) ON DELETE CASCADE,
                dayKey TEXT NOT NULL,
                recordedAt DOUBLE NOT NULL,
                recordedTimeZoneIdentifier TEXT NOT NULL,
                payloadJSON TEXT NOT NULL
            );

            CREATE UNIQUE INDEX IF NOT EXISTS trackingEntries_trackerId_dayKey
            ON trackingEntries(trackerId, dayKey);

            CREATE INDEX IF NOT EXISTS trackingEntries_dayKey
            ON trackingEntries(dayKey);

            CREATE TABLE IF NOT EXISTS userPreferences (
                singletonKey INTEGER PRIMARY KEY,
                weekStartsOn INTEGER NOT NULL,
                defaultHomeTab TEXT NOT NULL,
                preferredStatisticsWindow TEXT NOT NULL
            );
            """)

            let legacyHabitTableExists = try (Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'habits'"
            ) ?? 0) > 0
            let legacyCheckInTableExists = try (Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'checkIns'"
            ) ?? 0) > 0
            let trackerCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM trackers") ?? 0
            let entryCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM trackingEntries") ?? 0

            if legacyHabitTableExists && trackerCount == 0 {
                try db.execute(sql: """
                INSERT INTO trackers (
                    id, kind, name, colorToken, notes, scheduleType, scheduleWeekdays,
                    scheduleTargetCount, isArchived, createdAt, updatedAt
                )
                SELECT
                    id,
                    'habit',
                    name,
                    colorToken,
                    notes,
                    scheduleType,
                    scheduleWeekdays,
                    scheduleTargetCount,
                    isArchived,
                    createdAt,
                    updatedAt
                FROM habits;
                """)
            }

            if legacyCheckInTableExists && entryCount == 0 {
                try db.execute(sql: """
                INSERT INTO trackingEntries (
                    id, trackerId, dayKey, recordedAt, recordedTimeZoneIdentifier, payloadJSON
                )
                SELECT
                    id,
                    habitId,
                    dayKey,
                    completedAt,
                    recordedTimeZoneIdentifier,
                    '\(escapedDefaultPayloadJSON)'
                FROM checkIns;
                """)
            }
        }

        migrator.registerMigration("v2_tracking_entry_payloads") { db in
            let payloadColumnExists = try (Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM pragma_table_info('trackingEntries') WHERE name = 'payloadJSON'"
            ) ?? 0) > 0

            guard !payloadColumnExists else { return }

            try db.execute(sql: """
            ALTER TABLE trackingEntries
            ADD COLUMN payloadJSON TEXT NOT NULL DEFAULT '\(escapedDefaultPayloadJSON)';
            """)
        }

        return migrator
    }()

    private static func weekBounds(containing day: DayKey, weekStartsOn: MarkerWeekday) -> (start: DayKey, end: DayKey)? {
        guard let weekday = day.weekday else {
            return nil
        }

        let offset = (weekday.rawValue - weekStartsOn.rawValue + 7) % 7
        guard let start = day.addingDays(-offset),
              let end = start.addingDays(6) else {
            return nil
        }

        return (start, end)
    }

    private static let defaultPayloadJSON: String = {
        let payload = TrackingPayload.completion()
        let data = try? JSONEncoder().encode(payload)
        return String(data: data ?? Data("{}".utf8), encoding: .utf8) ?? "{}"
    }()

    private static var escapedDefaultPayloadJSON: String {
        defaultPayloadJSON.replacingOccurrences(of: "'", with: "''")
    }
}

private struct TrackerRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "trackers"

    var id: String
    let kind: String
    let name: String
    let colorToken: String
    let notes: String
    let scheduleType: String
    let scheduleWeekdays: String?
    let scheduleTargetCount: Int?
    let isArchived: Bool
    let createdAt: TimeInterval
    let updatedAt: TimeInterval

    init(_ tracker: Tracker) {
        id = tracker.id.uuidString
        kind = tracker.kind.rawValue
        name = tracker.name
        colorToken = tracker.colorToken
        notes = tracker.notes

        switch tracker.schedule {
        case .daily:
            scheduleType = "daily"
            scheduleWeekdays = nil
            scheduleTargetCount = nil
        case let .weeklyOnDays(days):
            scheduleType = "weeklyOnDays"
            scheduleWeekdays = days
                .map(\.rawValue)
                .sorted()
                .map(String.init)
                .joined(separator: ",")
            scheduleTargetCount = nil
        case let .weeklyQuota(targetCount):
            scheduleType = "weeklyQuota"
            scheduleWeekdays = nil
            scheduleTargetCount = targetCount
        }

        isArchived = tracker.isArchived
        createdAt = tracker.createdAt.timeIntervalSince1970
        updatedAt = tracker.updatedAt.timeIntervalSince1970
    }

    var domainModel: Tracker {
        Tracker(
            id: UUID(uuidString: id) ?? UUID(),
            kind: TrackerKind(rawValue: kind) ?? .custom,
            name: name,
            colorToken: colorToken,
            notes: notes,
            schedule: schedule,
            isArchived: isArchived,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }

    private var schedule: TrackerSchedule {
        switch scheduleType {
        case "daily":
            return .daily
        case "weeklyOnDays":
            let weekdays = scheduleWeekdays?
                .split(separator: ",")
                .compactMap { MarkerWeekday(rawValue: Int($0) ?? 0) } ?? []
            return .weeklyOnDays(Set(weekdays))
        case "weeklyQuota":
            return .weeklyQuota(targetCount: max(scheduleTargetCount ?? 1, 1))
        default:
            return .daily
        }
    }
}

private struct TrackingEntryRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "trackingEntries"

    var id: String
    let trackerId: String
    let dayKey: String
    let recordedAt: TimeInterval
    let recordedTimeZoneIdentifier: String
    let payloadJSON: String

    init(_ entry: TrackingEntry) {
        id = entry.id.uuidString
        trackerId = entry.trackerId.uuidString
        dayKey = entry.dayKey.rawValue
        recordedAt = entry.recordedAt.timeIntervalSince1970
        recordedTimeZoneIdentifier = entry.recordedTimeZoneIdentifier
        payloadJSON = Self.encodePayload(entry.payload)
    }

    var domainModel: TrackingEntry {
        TrackingEntry(
            id: UUID(uuidString: id) ?? UUID(),
            trackerId: UUID(uuidString: trackerId) ?? UUID(),
            dayKey: DayKey(rawValue: dayKey) ?? DayKey(year: 1970, month: 1, day: 1),
            recordedAt: Date(timeIntervalSince1970: recordedAt),
            recordedTimeZoneIdentifier: recordedTimeZoneIdentifier,
            payload: Self.decodePayload(payloadJSON)
        )
    }

    private static func encodePayload(_ payload: TrackingPayload) -> String {
        let data = try? JSONEncoder().encode(payload)
        return String(data: data ?? Data("{}".utf8), encoding: .utf8) ?? "{}"
    }

    private static func decodePayload(_ payloadJSON: String) -> TrackingPayload {
        guard let data = payloadJSON.data(using: .utf8),
              let payload = try? JSONDecoder().decode(TrackingPayload.self, from: data) else {
            return .completion()
        }

        return payload
    }
}

private struct UserPreferenceRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "userPreferences"

    var singletonKey: Int64 = 1
    let weekStartsOn: Int
    let defaultHomeTab: String
    let preferredStatisticsWindow: String

    init(_ preferences: UserPreference) {
        weekStartsOn = preferences.weekStartsOn.rawValue
        defaultHomeTab = preferences.defaultHomeTab.rawValue
        preferredStatisticsWindow = preferences.preferredStatisticsWindow.rawValue
    }

    var domainModel: UserPreference {
        UserPreference(
            weekStartsOn: MarkerWeekday(rawValue: weekStartsOn) ?? .monday,
            defaultHomeTab: HomeTabPreference(rawValue: defaultHomeTab) ?? .today,
            preferredStatisticsWindow: StatisticsWindow(rawValue: preferredStatisticsWindow) ?? .thirtyDays
        )
    }
}
