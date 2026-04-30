import XCTest
@testable import MarkerDesignSystem

final class MarkerDesignSystemTests: XCTestCase {
    func testBootstrapTokensRemainStable() {
        XCTAssertEqual(MarkerSpacing.screenPadding, 24)
        XCTAssertEqual(MarkerCornerRadius.card, 20)
    }
}
