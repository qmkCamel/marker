import Foundation
import XCTest
@testable import MarkerDomain

final class DayKeyTests: XCTestCase {
    func testCanonicalStringFormatRoundTrips() {
        let dayKey = DayKey(year: 2026, month: 4, day: 13)

        XCTAssertEqual(dayKey.rawValue, "2026-04-13")
        XCTAssertEqual(DayKey(rawValue: "2026-04-13"), dayKey)
    }

    func testDateUsesProvidedTimeZoneWhenDerivingDayKey() throws {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2026
        components.month = 4
        components.day = 13
        components.hour = 17
        components.minute = 30

        let date = try XCTUnwrap(components.date)
        let shanghai = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let losAngeles = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))

        XCTAssertEqual(
            DayKey(date: date, timeZone: shanghai).rawValue,
            "2026-04-14"
        )
        XCTAssertEqual(
            DayKey(date: date, timeZone: losAngeles).rawValue,
            "2026-04-13"
        )
    }
}
