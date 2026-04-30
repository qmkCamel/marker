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
        let nameField = element(identifier: "trackerEditor.name", in: app)
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Expected trackerEditor.name to be visible")
        assertVisible("trackerEditor.save", in: app)
        assertVisible("trackerEditor.cancel", in: app)

        nameField.tap()
        nameField.typeText("Walk")
        button(identifier: "trackerEditor.save", fallbackTitle: "Save", in: app).tap()

        XCTAssertTrue(app.staticTexts["Walk"].waitForExistence(timeout: 5), "Expected created tracker to be visible")
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
        if identified.exists {
            return identified
        }

        return app.buttons.matching(identifier: fallbackTitle).firstMatch
    }
}
