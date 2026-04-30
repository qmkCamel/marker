import Foundation
import XCTest
@testable import MarkerDomain

final class TrackerContractTypesTests: XCTestCase {
    func testCoreContractTypesCanBeConstructed() {
        let now = Date(timeIntervalSince1970: 1_776_096_000)
        let dayKey = DayKey(year: 2026, month: 4, day: 13)
        let schedule = TrackerSchedule.weeklyQuota(targetCount: 3)
        let trackerId = UUID()

        let tracker = Tracker(
            id: trackerId,
            kind: .habit,
            name: "Read",
            colorToken: "blue",
            notes: "20 minutes",
            schedule: schedule,
            isArchived: false,
            createdAt: now,
            updatedAt: now
        )
        let reminder = TrackerReminder(
            id: UUID(),
            trackerId: trackerId,
            localTime: LocalTime(hour: 8, minute: 30),
            weekdays: [.monday, .wednesday, .friday],
            isEnabled: true
        )
        let entry = TrackingEntry(
            id: UUID(),
            trackerId: trackerId,
            dayKey: dayKey,
            recordedAt: now,
            recordedTimeZoneIdentifier: "Asia/Shanghai"
        )
        let preference = UserPreference(
            weekStartsOn: .monday,
            defaultHomeTab: .today,
            preferredStatisticsWindow: .thirtyDays
        )

        XCTAssertEqual(tracker.schedule, schedule)
        XCTAssertEqual(reminder.localTime.hour, 8)
        XCTAssertEqual(entry.dayKey, dayKey)
        XCTAssertEqual(preference.defaultHomeTab, .today)
    }
}
