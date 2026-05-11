import Foundation
import MarkerData
import MarkerDomain
import XCTest
@testable import MarkerApp

@MainActor
final class MarkerAppModelTests: XCTestCase {
    func testEntryDraftUsesRequestedHistoricalDayAndExistingEntry() throws {
        let store = try MarkerSQLiteStore.inMemory()
        let tracker = makeTracker()
        let historicalDay = DayKey(year: 2026, month: 5, day: 3)
        let existingEntry = TrackingEntry(
            id: UUID(),
            trackerId: tracker.id,
            dayKey: historicalDay,
            recordedAt: Date(timeIntervalSince1970: 1_777_766_400),
            recordedTimeZoneIdentifier: "Asia/Shanghai",
            payload: .completion(note: "补记")
        )

        try store.saveTracker(tracker)
        try store.saveEntry(existingEntry)

        let model = MarkerAppModel(store: store)
        let draft = model.entryDraft(for: tracker, dayKey: historicalDay)

        XCTAssertEqual(draft.dayKey, historicalDay)
        XCTAssertEqual(draft.existingEntryID, existingEntry.id)
        XCTAssertEqual(draft.note, "补记")
    }

    func testDeleteEntryUsesRequestedHistoricalDay() throws {
        let store = try MarkerSQLiteStore.inMemory()
        let tracker = makeTracker()
        let today = DayKey(date: Date(), timeZone: .current)
        let historicalDay = today.addingDays(-1) ?? today

        try store.saveTracker(tracker)
        try store.saveEntry(
            TrackingEntry(
                id: UUID(),
                trackerId: tracker.id,
                dayKey: historicalDay,
                recordedAt: Date(),
                recordedTimeZoneIdentifier: "Asia/Shanghai"
            )
        )
        try store.saveEntry(
            TrackingEntry(
                id: UUID(),
                trackerId: tracker.id,
                dayKey: today,
                recordedAt: Date(),
                recordedTimeZoneIdentifier: "Asia/Shanghai"
            )
        )

        let model = MarkerAppModel(store: store)
        model.deleteEntry(for: tracker, dayKey: historicalDay)

        XCTAssertFalse(model.entries.contains { $0.trackerId == tracker.id && $0.dayKey == historicalDay })
        XCTAssertTrue(model.entries.contains { $0.trackerId == tracker.id && $0.dayKey == today })
    }

    private func makeTracker() -> Tracker {
        Tracker(
            id: UUID(),
            kind: .habit,
            name: "Walk",
            colorToken: "blue",
            notes: "",
            schedule: .daily,
            isArchived: false,
            createdAt: Date(timeIntervalSince1970: 1_777_766_400),
            updatedAt: Date(timeIntervalSince1970: 1_777_766_400)
        )
    }
}
