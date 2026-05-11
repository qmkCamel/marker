import XCTest

@MainActor
final class MarkerAppSmokeUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
    }

    func testTopLevelTabsAreAccessible() {
        let app = makeApp()
        app.launch()

        assertVisible("screen.today", in: app)
        openTab(identifier: "tab.history", fallbackTitle: "History", in: app)
        assertVisible("screen.history", in: app)
        openTab(identifier: "tab.statistics", fallbackTitle: "Statistics", in: app)
        assertVisible("screen.statistics", in: app)
        openTab(identifier: "tab.settings", fallbackTitle: "Settings", in: app)
        assertVisible("screen.settings", in: app)
    }

    func testCanCreateTrackerFromEditor() {
        let app = makeApp()
        app.launch()

        button(identifier: "today.addTracker", fallbackTitle: "Add", in: app).tap()
        button(identifier: "trackerTemplate.medication", fallbackTitle: "用药", in: app).tap()
        let nameField = element(identifier: "trackerEditor.name", in: app)
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Expected trackerEditor.name to be visible")
        assertVisible("trackerEditor.save", in: app)
        assertVisible("trackerEditor.cancel", in: app)

        nameField.tap()
        nameField.typeText("Vitamin D")
        button(identifier: "trackerEditor.save", fallbackTitle: "Save", in: app).tap()

        XCTAssertTrue(app.staticTexts["Vitamin D"].waitForExistence(timeout: 5), "Expected created tracker to be visible")
    }

    func testCanBackfillHistoricalEntryFromHistory() {
        let app = makeApp()
        app.launch()

        openTab(identifier: "tab.history", fallbackTitle: "History", in: app)
        button(identifier: "history.backfill", fallbackTitle: "Backfill", in: app).tap()
        button(identifier: "history.backfill.continue", fallbackTitle: "继续", in: app).tap()
        app.swipeUp()
        button(identifier: "trackingEntryEditor.save", fallbackTitle: "保存", in: app).tap()

        XCTAssertTrue(app.staticTexts["完成 2 项"].waitForExistence(timeout: 5), "Expected historical day to include the backfilled entry")
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--uitesting",
            "--reset-data",
            "--seed-demo-data"
        ]
        return app
    }

    private func openTab(identifier: String, fallbackTitle: String, in app: XCUIApplication) {
        let tab = button(identifier: identifier, fallbackTitle: fallbackTitle, in: app)
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "Expected tab \(identifier) to exist")
        tab.tap()
    }

    private func assertVisible(_ identifier: String, in app: XCUIApplication) {
        XCTAssertTrue(
            element(identifier: identifier, in: app).waitForExistence(timeout: 5),
            "Expected \(identifier) to be visible"
        )
    }

    private func element(identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func button(identifier: String, fallbackTitle: String, in app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons.matching(identifier: identifier).firstMatch
        if identified.waitForExistence(timeout: 2) {
            return identified
        }

        return app.buttons.matching(identifier: fallbackTitle).firstMatch
    }
}
