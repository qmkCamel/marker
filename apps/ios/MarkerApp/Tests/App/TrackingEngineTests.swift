import Foundation
import XCTest
@testable import MarkerApp
import MarkerDomain

final class TrackingEngineTests: XCTestCase {
    func testBuildTodayItemsIncludesOnlyDueActiveTrackers() {
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let today = DayKey(year: 2026, month: 4, day: 13) // Monday
        let activeDaily = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Read",
            colorToken: "blue",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let activeMonday = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Workout",
            colorToken: "green",
            notes: "",
            schedule: .weeklyOnDays([.monday]),
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let inactiveTuesday = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Call Mom",
            colorToken: "pink",
            notes: "",
            schedule: .weeklyOnDays([.tuesday]),
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let archived = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Archive Me",
            colorToken: "gray",
            notes: "",
            schedule: .daily,
            isArchived: true,
            createdAt: now,
            updatedAt: now
        )

        let items = TrackingEngine.buildTodayItems(
            trackers: [activeDaily, activeMonday, inactiveTuesday, archived],
            entries: [],
            dayKey: today,
            weekStartsOn: .monday
        )

        XCTAssertEqual(items.map(\.tracker.id), [activeDaily.id, activeMonday.id])
    }

    func testBuildTodayOverviewSeparatesPendingAndRecordedItems() {
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let today = DayKey(year: 2026, month: 4, day: 13)
        let pendingTracker = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Water",
            colorToken: "blue",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let recordedTracker = Tracker(
            id: UUID(),
            kind: .medication,
            name: "Vitamin D",
            colorToken: "green",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: now.addingTimeInterval(1),
            updatedAt: now
        )
        let entry = TrackingEntry(
            id: UUID(),
            trackerId: recordedTracker.id,
            dayKey: today,
            recordedAt: now,
            recordedTimeZoneIdentifier: "Asia/Shanghai",
            payload: .medication(status: .taken, dose: 1, unit: "片", note: "饭后")
        )

        let overview = TrackingEngine.buildTodayOverview(
            trackers: [pendingTracker, recordedTracker],
            entries: [entry],
            dayKey: today,
            weekStartsOn: .monday
        )

        XCTAssertEqual(overview.pendingItems.map(\.tracker.id), [pendingTracker.id])
        XCTAssertEqual(overview.recordedItems.map(\.tracker.id), [recordedTracker.id])
        XCTAssertEqual(overview.summaryText, "今天还有 1 项待确认")
        XCTAssertEqual(overview.recordedItems.first?.entrySummaryText, "已服用 · 1 片 · 饭后")
    }

    func testBuildTodayOverviewTreatsSkippedMedicationAsRecordedButNotCompleted() {
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let today = DayKey(year: 2026, month: 4, day: 13)
        let medication = Tracker(
            id: UUID(),
            kind: .medication,
            name: "Vitamin D",
            colorToken: "green",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let skippedEntry = TrackingEntry(
            id: UUID(),
            trackerId: medication.id,
            dayKey: today,
            recordedAt: now,
            recordedTimeZoneIdentifier: "Asia/Shanghai",
            payload: .medication(status: .skipped, dose: 1, unit: "片", note: "饭后")
        )

        let overview = TrackingEngine.buildTodayOverview(
            trackers: [medication],
            entries: [skippedEntry],
            dayKey: today,
            weekStartsOn: .monday
        )

        XCTAssertTrue(overview.pendingItems.isEmpty)
        XCTAssertEqual(overview.recordedItems.count, 1)
        XCTAssertTrue(overview.recordedItems[0].hasRecord)
        XCTAssertFalse(overview.recordedItems[0].isCompleted)
        XCTAssertTrue(overview.recordedItems[0].isSkippedMedication)
        XCTAssertEqual(overview.summaryText, "今天的记录已保存")
    }

    func testBuildStatisticsSummaryReflectsCurrentWindow() {
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let today = DayKey(year: 2026, month: 4, day: 13)
        let yesterday = DayKey(year: 2026, month: 4, day: 12)
        let createdAt = yesterday.date ?? now
        let tracker = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Read",
            colorToken: "blue",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: createdAt,
            updatedAt: now
        )

        let summary = TrackingEngine.buildStatisticsSummary(
            trackers: [tracker],
            entries: [
                TrackingEntry(
                    id: UUID(),
                    trackerId: tracker.id,
                    dayKey: today,
                    recordedAt: now,
                    recordedTimeZoneIdentifier: "Asia/Shanghai"
                ),
                TrackingEntry(
                    id: UUID(),
                    trackerId: tracker.id,
                    dayKey: yesterday,
                    recordedAt: now.addingTimeInterval(-86_400),
                    recordedTimeZoneIdentifier: "Asia/Shanghai"
                )
            ],
            today: today,
            preferences: .defaultValue
        )

        XCTAssertEqual(summary.activeTrackerCount, 1)
        XCTAssertEqual(summary.totalEntryCount, 2)
        XCTAssertGreaterThan(summary.currentWindowCompletionRate, 0)
    }
}
