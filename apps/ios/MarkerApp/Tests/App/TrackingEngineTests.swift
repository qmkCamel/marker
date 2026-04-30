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
