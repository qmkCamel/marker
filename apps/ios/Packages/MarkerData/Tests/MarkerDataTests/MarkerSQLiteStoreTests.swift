import Foundation
import GRDB
import XCTest
@testable import MarkerData
import MarkerDomain

final class MarkerSQLiteStoreTests: XCTestCase {
    func testSavingTrackerPersistsAndSeparatesArchivedFromActive() throws {
        let store = try MarkerSQLiteStore.inMemory()
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let activeTracker = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Read",
            colorToken: "blue",
            notes: "20 minutes",
            schedule: .daily,
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let archivedTracker = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Walk",
            colorToken: "green",
            notes: "",
            schedule: .daily,
            isArchived: true,
            createdAt: now,
            updatedAt: now
        )

        try store.saveTracker(activeTracker)
        try store.saveTracker(archivedTracker)

        XCTAssertEqual(try store.fetchActiveTrackers().map(\.id), [activeTracker.id])
        XCTAssertEqual(try store.fetchArchivedTrackers().map(\.id), [archivedTracker.id])
    }

    func testEntryQueriesUseDayKeyAndWeeklyCompletionCount() throws {
        let store = try MarkerSQLiteStore.inMemory()
        let trackerId = UUID()
        let monday = DayKey(year: 2026, month: 4, day: 13)
        let wednesday = DayKey(year: 2026, month: 4, day: 15)
        let nextWeekMonday = DayKey(year: 2026, month: 4, day: 20)
        let now = Date(timeIntervalSince1970: 1_776_096_000)

        try store.saveTracker(
            Tracker(
                id: trackerId,
                kind: .habit,
                name: "Workout",
                colorToken: "orange",
                notes: "",
                schedule: .weeklyQuota(targetCount: 3),
                isArchived: false,
                createdAt: now,
                updatedAt: now
            )
        )

        try store.saveEntry(
            TrackingEntry(
                id: UUID(),
                trackerId: trackerId,
                dayKey: monday,
                recordedAt: now,
                recordedTimeZoneIdentifier: "Asia/Shanghai"
            )
        )
        try store.saveEntry(
            TrackingEntry(
                id: UUID(),
                trackerId: trackerId,
                dayKey: wednesday,
                recordedAt: now.addingTimeInterval(86_400),
                recordedTimeZoneIdentifier: "Asia/Shanghai"
            )
        )
        try store.saveEntry(
            TrackingEntry(
                id: UUID(),
                trackerId: trackerId,
                dayKey: nextWeekMonday,
                recordedAt: now.addingTimeInterval(7 * 86_400),
                recordedTimeZoneIdentifier: "Asia/Shanghai"
            )
        )

        XCTAssertEqual(try store.fetchEntries(on: monday).count, 1)
        XCTAssertEqual(
            try store.fetchWeeklyEntryCount(
                trackerId: trackerId,
                for: wednesday,
                weekStartsOn: .monday
            ),
            2
        )
        XCTAssertEqual(
            try store.fetchWeeklyEntryCount(
                trackerId: trackerId,
                for: nextWeekMonday,
                weekStartsOn: .monday
            ),
            1
        )
    }

    func testSavingPreferencesPersistsLatestValues() throws {
        let store = try MarkerSQLiteStore.inMemory()

        try store.savePreferences(
            UserPreference(
                weekStartsOn: .sunday,
                defaultHomeTab: .statistics,
                preferredStatisticsWindow: .ninetyDays
            )
        )

        let preferences = try XCTUnwrap(try store.fetchPreferences())
        XCTAssertEqual(preferences.weekStartsOn, .sunday)
        XCTAssertEqual(preferences.defaultHomeTab, .statistics)
        XCTAssertEqual(preferences.preferredStatisticsWindow, .ninetyDays)
    }

    func testSavingEntryPersistsPayloadRoundTrip() throws {
        let store = try MarkerSQLiteStore.inMemory()
        let trackerId = UUID()
        let dayKey = DayKey(year: 2026, month: 4, day: 13)
        let now = Date(timeIntervalSince1970: 1_776_096_000)

        try store.saveTracker(
            Tracker(
                id: trackerId,
                kind: .medication,
                name: "Vitamin D",
                colorToken: "orange",
                notes: "",
                schedule: .daily,
                isArchived: false,
                createdAt: now,
                updatedAt: now
            )
        )

        let entry = TrackingEntry(
            id: UUID(),
            trackerId: trackerId,
            dayKey: dayKey,
            recordedAt: now,
            recordedTimeZoneIdentifier: "Asia/Shanghai",
            payload: .medication(status: .taken, dose: 1, unit: "片", note: "早餐后")
        )

        try store.saveEntry(entry)

        let fetched = try XCTUnwrap(try store.fetchEntry(trackerId: trackerId, dayKey: dayKey))
        XCTAssertEqual(fetched.payload, entry.payload)
        XCTAssertEqual(fetched.payload.summary, "已服用 · 1 片 · 早餐后")
    }

    func testLegacyTrackingEntriesMigrateToDefaultCompletionPayload() throws {
        let trackerId = UUID()
        let dayKey = DayKey(year: 2026, month: 4, day: 13)
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let databaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")

        let legacyQueue = try DatabaseQueue(path: databaseURL.path)
        try legacyQueue.write { db in
            try db.execute(sql: """
            CREATE TABLE trackers (
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

            CREATE TABLE trackingEntries (
                id TEXT PRIMARY KEY,
                trackerId TEXT NOT NULL REFERENCES trackers(id) ON DELETE CASCADE,
                dayKey TEXT NOT NULL,
                recordedAt DOUBLE NOT NULL,
                recordedTimeZoneIdentifier TEXT NOT NULL
            );

            CREATE TABLE userPreferences (
                singletonKey INTEGER PRIMARY KEY,
                weekStartsOn INTEGER NOT NULL,
                defaultHomeTab TEXT NOT NULL,
                preferredStatisticsWindow TEXT NOT NULL
            );
            """)

            try db.execute(
                sql: """
                INSERT INTO trackers (
                    id, kind, name, colorToken, notes, scheduleType, scheduleWeekdays,
                    scheduleTargetCount, isArchived, createdAt, updatedAt
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                arguments: [
                    trackerId.uuidString,
                    "habit",
                    "Read",
                    "blue",
                    "",
                    "daily",
                    nil,
                    nil,
                    false,
                    now.timeIntervalSince1970,
                    now.timeIntervalSince1970
                ]
            )

            try db.execute(
                sql: """
                INSERT INTO trackingEntries (
                    id, trackerId, dayKey, recordedAt, recordedTimeZoneIdentifier
                ) VALUES (?, ?, ?, ?, ?)
                """,
                arguments: [
                    UUID().uuidString,
                    trackerId.uuidString,
                    dayKey.rawValue,
                    now.timeIntervalSince1970,
                    "Asia/Shanghai"
                ]
            )
        }

        let store = try MarkerSQLiteStore(path: databaseURL.path)
        let migratedEntry = try XCTUnwrap(try store.fetchEntry(trackerId: trackerId, dayKey: dayKey))

        XCTAssertEqual(migratedEntry.payload, .completion())
    }
}
