import XCTest
@testable import MarkerDomain

final class TrackerScheduleTests: XCTestCase {
    func testDailyScheduleIsDueOnAnyDay() {
        let monday = DayKey(year: 2026, month: 4, day: 13)

        XCTAssertTrue(TrackerSchedule.daily.isDue(on: monday))
    }

    func testWeeklyOnDaysIsDueOnlyOnSelectedWeekdays() {
        let monday = DayKey(year: 2026, month: 4, day: 13)
        let tuesday = DayKey(year: 2026, month: 4, day: 14)
        let schedule = TrackerSchedule.weeklyOnDays([.monday, .wednesday, .friday])

        XCTAssertTrue(schedule.isDue(on: monday))
        XCTAssertFalse(schedule.isDue(on: tuesday))
    }

    func testWeeklyQuotaRemainsDueUntilTargetReached() {
        let monday = DayKey(year: 2026, month: 4, day: 13)
        let schedule = TrackerSchedule.weeklyQuota(targetCount: 3)

        XCTAssertTrue(schedule.isDue(on: monday, completedCountInWeek: 0))
        XCTAssertTrue(schedule.isDue(on: monday, completedCountInWeek: 2))
    }

    func testWeeklyQuotaStopsBeingDueAfterQuotaIsSatisfied() {
        let monday = DayKey(year: 2026, month: 4, day: 13)
        let schedule = TrackerSchedule.weeklyQuota(targetCount: 3)

        XCTAssertFalse(schedule.isDue(on: monday, completedCountInWeek: 3))
    }
}
