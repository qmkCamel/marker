import Foundation
import XCTest
@testable import MarkerApp
import MarkerDomain

final class TrackerDraftTests: XCTestCase {
    func testEmptyNameIsInvalid() {
        var draft = TrackerDraft.empty
        draft.name = "   "

        XCTAssertEqual(draft.validationMessage, "请输入追踪项名称")
    }

    func testWeeklyOnDaysRequiresAtLeastOneWeekday() {
        var draft = TrackerDraft.empty
        draft.name = "Workout"
        draft.scheduleKind = .weeklyOnDays
        draft.selectedWeekdays = []

        XCTAssertEqual(draft.validationMessage, "请选择至少一个星期")
    }

    func testWeeklyQuotaRequiresPositiveTarget() {
        var draft = TrackerDraft.empty
        draft.name = "Read"
        draft.scheduleKind = .weeklyQuota
        draft.weeklyQuotaTarget = 0

        XCTAssertEqual(draft.validationMessage, "每周目标次数必须大于 0")
    }

    func testTemplateDraftUsesKindDefaults() {
        let medication = TrackerDraft.template(for: .medication)
        let cycle = TrackerDraft.template(for: .cycle)
        let custom = TrackerDraft.template(for: .custom)

        XCTAssertEqual(medication.kind, .medication)
        XCTAssertEqual(medication.colorToken, "blue")
        XCTAssertEqual(medication.scheduleKind, .daily)
        XCTAssertEqual(cycle.kind, .cycle)
        XCTAssertEqual(cycle.colorToken, "pink")
        XCTAssertEqual(custom.kind, .custom)
        XCTAssertEqual(custom.colorToken, "purple")
    }
}
