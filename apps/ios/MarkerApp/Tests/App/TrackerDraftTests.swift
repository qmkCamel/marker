import Foundation
import XCTest
@testable import MarkerApp

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
}
