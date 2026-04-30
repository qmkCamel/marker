import XCTest
@testable import MarkerApp

final class AppDestinationTests: XCTestCase {
    func testTopLevelDestinationsExposeExpectedTitlesInOrder() {
        XCTAssertEqual(
            AppDestination.allCases.map(\.title),
            ["Today", "History", "Statistics", "Settings"]
        )
    }

    func testTopLevelDestinationsExposeExpectedSystemImages() {
        XCTAssertEqual(
            AppDestination.allCases.map(\.systemImage),
            ["checklist", "calendar", "chart.bar", "gearshape"]
        )
    }
}
