import Foundation
import XCTest
@testable import MarkerApp
import MarkerDomain

final class TrackingEntryDraftTests: XCTestCase {
    func testMedicationDraftBuildsMedicationPayload() {
        let tracker = Tracker(
            id: UUID(),
            kind: .medication,
            name: "Vitamin D",
            colorToken: "orange",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: Date(timeIntervalSince1970: 1_776_096_000),
            updatedAt: Date(timeIntervalSince1970: 1_776_096_000)
        )
        var draft = TrackingEntryDraft(tracker: tracker, dayKey: DayKey(year: 2026, month: 4, day: 13))
        draft.medicationStatus = .taken
        draft.doseText = "1"
        draft.unit = "片"
        draft.note = "早餐后"

        let entry = draft.makeEntry()

        XCTAssertEqual(
            entry.payload,
            .medication(status: .taken, dose: 1, unit: "片", note: "早餐后")
        )
    }

    func testCustomNoteDraftRequiresNote() {
        let tracker = Tracker(
            id: UUID(),
            kind: .custom,
            name: "Daily Notes",
            colorToken: "purple",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: Date(timeIntervalSince1970: 1_776_096_000),
            updatedAt: Date(timeIntervalSince1970: 1_776_096_000)
        )
        var draft = TrackingEntryDraft(tracker: tracker, dayKey: DayKey(year: 2026, month: 4, day: 13))
        draft.note = "   "

        XCTAssertEqual(draft.validationMessage, "请输入记录内容")
    }

    func testDraftPreservesExistingEntryTimeZone() {
        let tracker = Tracker(
            id: UUID(),
            kind: .habit,
            name: "Walk",
            colorToken: "green",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: Date(timeIntervalSince1970: 1_776_096_000),
            updatedAt: Date(timeIntervalSince1970: 1_776_096_000)
        )
        let entry = TrackingEntry(
            id: UUID(),
            trackerId: tracker.id,
            dayKey: DayKey(year: 2026, month: 4, day: 13),
            recordedAt: Date(timeIntervalSince1970: 1_776_096_000),
            recordedTimeZoneIdentifier: "Asia/Tokyo",
            payload: .completion()
        )

        let draft = TrackingEntryDraft(tracker: tracker, dayKey: entry.dayKey, existingEntry: entry)

        XCTAssertEqual(draft.recordedTimeZoneIdentifier, "Asia/Tokyo")
        XCTAssertEqual(draft.makeEntry().recordedTimeZoneIdentifier, "Asia/Tokyo")
    }
}
