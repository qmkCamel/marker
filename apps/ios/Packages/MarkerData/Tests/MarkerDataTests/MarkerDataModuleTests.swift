import XCTest
@testable import MarkerData
import MarkerDomain

final class MarkerDataModuleTests: XCTestCase {
    func testSupportedBoundariesMatchDomainBootstrapContracts() {
        XCTAssertEqual(
            MarkerDataModule.supportedBoundaries,
            MarkerDomainModule.defaultBoundaries
        )
    }
}
