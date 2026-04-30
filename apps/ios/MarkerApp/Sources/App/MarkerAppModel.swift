import Combine
import Foundation
import MarkerData
import MarkerDomain

@MainActor
final class MarkerAppModel: ObservableObject {
    @Published private(set) var trackers: [Tracker] = []
    @Published private(set) var entries: [TrackingEntry] = []
    @Published var preferences: UserPreference = .defaultValue
    @Published var lastErrorMessage: String?

    private let store: MarkerSQLiteStore

    init(store: MarkerSQLiteStore) {
        self.store = store
        reload()
    }

    var todayKey: DayKey {
        DayKey(date: Date(), timeZone: .current)
    }

    var todayItems: [TodayTrackerItem] {
        TrackingEngine.buildTodayItems(
            trackers: trackers,
            entries: entries,
            dayKey: todayKey,
            weekStartsOn: preferences.weekStartsOn
        )
    }

    var historySections: [HistoryDaySection] {
        TrackingEngine.buildHistorySections(trackers: trackers, entries: entries)
    }

    var statisticsSummary: StatisticsSummary {
        TrackingEngine.buildStatisticsSummary(
            trackers: trackers,
            entries: entries,
            today: todayKey,
            preferences: preferences
        )
    }

    var archivedTrackers: [Tracker] {
        trackers.filter(\.isArchived)
    }

    func entryDraft(for tracker: Tracker) -> TrackingEntryDraft {
        TrackingEntryDraft(
            tracker: tracker,
            dayKey: todayKey,
            existingEntry: entryForToday(trackerID: tracker.id)
        )
    }

    func clearError() {
        lastErrorMessage = nil
    }

    func reload() {
        do {
            trackers = try store.fetchAllTrackers()
            entries = try store.fetchAllEntries()
            preferences = try store.fetchPreferences() ?? .defaultValue
            if try store.fetchPreferences() == nil {
                try store.savePreferences(.defaultValue)
            }
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func saveTracker(from draft: TrackerDraft) {
        guard draft.validationMessage == nil else {
            lastErrorMessage = draft.validationMessage
            return
        }

        do {
            try store.saveTracker(draft.makeTracker())
            reload()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func toggleEntry(for tracker: Tracker) {
        do {
            if entryForToday(trackerID: tracker.id) != nil {
                try store.deleteEntry(trackerId: tracker.id, dayKey: todayKey)
            } else {
                try store.saveEntry(
                    TrackingEntry(
                        id: UUID(),
                        trackerId: tracker.id,
                        dayKey: todayKey,
                        recordedAt: Date(),
                        recordedTimeZoneIdentifier: TimeZone.current.identifier
                    )
                )
            }
            reload()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func saveEntry(from draft: TrackingEntryDraft) {
        guard draft.validationMessage == nil else {
            lastErrorMessage = draft.validationMessage
            return
        }

        do {
            try store.saveEntry(draft.makeEntry())
            reload()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func deleteTodayEntry(for tracker: Tracker) {
        do {
            try store.deleteEntry(trackerId: tracker.id, dayKey: todayKey)
            reload()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func restoreTracker(_ tracker: Tracker) {
        var draft = TrackerDraft(tracker: tracker)
        draft.isArchived = false
        saveTracker(from: draft)
    }

    func updateWeekStartsOn(_ weekday: MarkerWeekday) {
        savePreferences(
            UserPreference(
                weekStartsOn: weekday,
                defaultHomeTab: preferences.defaultHomeTab,
                preferredStatisticsWindow: preferences.preferredStatisticsWindow
            )
        )
    }

    func updateStatisticsWindow(_ window: StatisticsWindow) {
        savePreferences(
            UserPreference(
                weekStartsOn: preferences.weekStartsOn,
                defaultHomeTab: preferences.defaultHomeTab,
                preferredStatisticsWindow: window
            )
        )
    }

    private func savePreferences(_ newPreferences: UserPreference) {
        do {
            try store.savePreferences(newPreferences)
            reload()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func entryForToday(trackerID: UUID) -> TrackingEntry? {
        entries.first { $0.trackerId == trackerID && $0.dayKey == todayKey }
    }
}
