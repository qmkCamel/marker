import XCTest
@testable import MarkerDomain

final class MarkerDomainModuleTests: XCTestCase {
    func testDefaultBoundariesCoverExpectedRepositoryContracts() {
        XCTAssertEqual(
            MarkerDomainModule.defaultBoundaries,
            [
                .trackerRepository,
                .trackingEntryRepository,
                .statisticsRepository,
                .trackerReminderScheduler
            ]
        )
    }
}
