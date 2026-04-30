import XCTest
@testable import MarkerDomain

final class TrackingPayloadTests: XCTestCase {
    func testMedicationPayloadProvidesSummaryAndCompletionSemantics() {
        let payload = TrackingPayload.medication(
            status: .skipped,
            dose: 1,
            unit: "片",
            note: "饭后"
        )

        XCTAssertEqual(payload.summary, "已跳过 · 1 片 · 饭后")
        XCTAssertFalse(payload.countsAsCompletion)
    }

    func testCyclePayloadProvidesReadableSummary() {
        let payload = TrackingPayload.cycle(
            flow: .medium,
            symptoms: [.cramp, .fatigue],
            note: "第二天"
        )

        XCTAssertTrue(payload.summary.contains("中量"))
        XCTAssertTrue(payload.summary.contains("腹痛"))
        XCTAssertTrue(payload.summary.contains("疲劳"))
        XCTAssertTrue(payload.summary.contains("第二天"))
        XCTAssertTrue(payload.countsAsCompletion)
    }
}
