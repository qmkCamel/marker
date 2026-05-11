import Foundation
import MarkerDomain

struct TodayTrackerItem: Identifiable {
    let tracker: Tracker
    let entry: TrackingEntry?
    let weeklyProgressText: String?

    var id: UUID { tracker.id }
    var hasRecord: Bool { entry != nil }
    var isCompleted: Bool { entry?.countsAsCompletion ?? false }
    var entrySummaryText: String? { entry?.summary }
    var isSkippedMedication: Bool {
        entry?.payload.kind == .medication && entry?.payload.medicationStatus == .skipped
    }
}

struct TodayOverview {
    let activeTrackerCount: Int
    let pendingItems: [TodayTrackerItem]
    let recordedItems: [TodayTrackerItem]

    var allItems: [TodayTrackerItem] {
        pendingItems + recordedItems
    }

    var summaryText: String {
        if activeTrackerCount == 0 {
            return "先记录一件照顾自己的事"
        }

        if pendingItems.isEmpty && recordedItems.isEmpty {
            return "今天没有需要记录的项目"
        }

        if pendingItems.isEmpty {
            return "今天的记录已保存"
        }

        return "今天还有 \(pendingItems.count) 项待确认"
    }
}

struct HistoryDayItem: Identifiable {
    let trackerName: String
    let colorToken: String
    let recordedAt: Date
    let payloadSummary: String

    var id: String { "\(trackerName)-\(recordedAt.timeIntervalSince1970)" }
}

struct HistoryDaySection: Identifiable {
    let dayKey: DayKey
    let items: [HistoryDayItem]

    var id: String { dayKey.rawValue }
}

struct TrackerCompletionSummary: Identifiable {
    let trackerID: UUID
    let trackerName: String
    let colorToken: String
    let totalEntryCount: Int

    var id: UUID { trackerID }
}

struct StatisticsSummary {
    let activeTrackerCount: Int
    let totalEntryCount: Int
    let currentWindowCompletedCount: Int
    let currentWindowDueCount: Int
    let currentWindowCompletionRate: Double
    let currentStreakDays: Int
    let trackerBreakdown: [TrackerCompletionSummary]
}

enum TrackingEngine {
    static func buildTodayOverview(
        trackers: [Tracker],
        entries: [TrackingEntry],
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday
    ) -> TodayOverview {
        let activeTrackers = trackers.filter { !$0.isArchived }
        let todayEntries = Dictionary(uniqueKeysWithValues: entries
            .filter { $0.dayKey == dayKey }
            .map { ($0.trackerId, $0) })

        var pendingItems: [TodayTrackerItem] = []
        var recordedItems: [TodayTrackerItem] = []

        for tracker in activeTrackers.sorted(by: { $0.createdAt < $1.createdAt }) {
            let todayEntry = todayEntries[tracker.id]
            let weeklyCountBeforeToday = completionCountBeforeDay(
                entries: entries,
                trackerID: tracker.id,
                dayKey: dayKey,
                weekStartsOn: weekStartsOn
            )
            let isDue = tracker.schedule.isDue(on: dayKey, completedCountInWeek: weeklyCountBeforeToday)

            guard isDue || todayEntry != nil else { continue }

            let weeklyProgressText: String?
            if case let .weeklyQuota(targetCount) = tracker.schedule {
                let completedCount = completionCountBeforeOrOnDay(
                    entries: entries,
                    trackerID: tracker.id,
                    dayKey: dayKey,
                    weekStartsOn: weekStartsOn
                )
                weeklyProgressText = "\(min(completedCount, targetCount))/\(targetCount)"
            } else {
                weeklyProgressText = nil
            }

            let item = TodayTrackerItem(
                tracker: tracker,
                entry: todayEntry,
                weeklyProgressText: weeklyProgressText
            )

            if todayEntry == nil {
                pendingItems.append(item)
            } else {
                recordedItems.append(item)
            }
        }

        return TodayOverview(
            activeTrackerCount: activeTrackers.count,
            pendingItems: pendingItems,
            recordedItems: recordedItems
        )
    }

    static func buildTodayItems(
        trackers: [Tracker],
        entries: [TrackingEntry],
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday
    ) -> [TodayTrackerItem] {
        buildTodayOverview(
            trackers: trackers,
            entries: entries,
            dayKey: dayKey,
            weekStartsOn: weekStartsOn
        )
        .allItems
    }

    static func buildHistorySections(trackers: [Tracker], entries: [TrackingEntry]) -> [HistoryDaySection] {
        let trackerLookup = Dictionary(uniqueKeysWithValues: trackers.map { ($0.id, $0) })
        let grouped = Dictionary(grouping: entries, by: \.dayKey)

        return grouped
            .keys
            .sorted(by: >)
            .map { dayKey in
                let items = grouped[dayKey, default: []]
                    .sorted { $0.recordedAt > $1.recordedAt }
                    .compactMap { entry -> HistoryDayItem? in
                        guard let tracker = trackerLookup[entry.trackerId] else { return nil }

                        return HistoryDayItem(
                            trackerName: tracker.name,
                            colorToken: tracker.colorToken,
                            recordedAt: entry.recordedAt,
                            payloadSummary: entry.summary
                        )
                    }

                return HistoryDaySection(dayKey: dayKey, items: items)
            }
            .filter { !$0.items.isEmpty }
    }

    static func buildStatisticsSummary(
        trackers: [Tracker],
        entries: [TrackingEntry],
        today: DayKey,
        preferences: UserPreference
    ) -> StatisticsSummary {
        let activeTrackers = trackers.filter { !$0.isArchived }
        let allEntryCount = entries.count
        let windowStart = today.addingDays(-(preferences.preferredStatisticsWindow.dayCount - 1)) ?? today
        let completedKeys = Set(entries.filter(\.countsAsCompletion).map { key(trackerID: $0.trackerId, dayKey: $0.dayKey) })

        var dueCount = 0
        var completedCount = 0
        var currentDay = windowStart

        while currentDay <= today {
            for tracker in activeTrackers where trackerCreatedDayKey(for: tracker) <= currentDay {
                let weeklyCountBeforeDay = completionCountBeforeDay(
                    entries: entries,
                    trackerID: tracker.id,
                    dayKey: currentDay,
                    weekStartsOn: preferences.weekStartsOn
                )

                if tracker.schedule.isDue(on: currentDay, completedCountInWeek: weeklyCountBeforeDay) {
                    dueCount += 1
                    if completedKeys.contains(key(trackerID: tracker.id, dayKey: currentDay)) {
                        completedCount += 1
                    }
                }
            }

            guard let nextDay = currentDay.addingDays(1) else { break }
            currentDay = nextDay
        }

        let currentStreakDays = buildCurrentStreakDays(entries: entries, today: today)
        let trackerBreakdown = activeTrackers.map { tracker in
            TrackerCompletionSummary(
                trackerID: tracker.id,
                trackerName: tracker.name,
                colorToken: tracker.colorToken,
                totalEntryCount: entries.filter { $0.trackerId == tracker.id }.count
            )
        }
        .sorted {
            if $0.totalEntryCount == $1.totalEntryCount {
                return $0.trackerName < $1.trackerName
            }

            return $0.totalEntryCount > $1.totalEntryCount
        }

        let rate = dueCount == 0 ? 0 : Double(completedCount) / Double(dueCount)

        return StatisticsSummary(
            activeTrackerCount: activeTrackers.count,
            totalEntryCount: allEntryCount,
            currentWindowCompletedCount: completedCount,
            currentWindowDueCount: dueCount,
            currentWindowCompletionRate: rate,
            currentStreakDays: currentStreakDays,
            trackerBreakdown: trackerBreakdown
        )
    }

    private static func buildCurrentStreakDays(entries: [TrackingEntry], today: DayKey) -> Int {
        let completedDays = Set(entries.filter(\.countsAsCompletion).map(\.dayKey))
        var streak = 0
        var cursor = today

        while completedDays.contains(cursor) {
            streak += 1
            guard let previousDay = cursor.addingDays(-1) else { break }
            cursor = previousDay
        }

        return streak
    }

    private static func completionCountBeforeOrOnDay(
        entries: [TrackingEntry],
        trackerID: UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday
    ) -> Int {
        completionCount(
            entries: entries,
            trackerID: trackerID,
            dayKey: dayKey,
            weekStartsOn: weekStartsOn,
            includeCurrentDay: true
        )
    }

    private static func completionCountBeforeDay(
        entries: [TrackingEntry],
        trackerID: UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday
    ) -> Int {
        completionCount(
            entries: entries,
            trackerID: trackerID,
            dayKey: dayKey,
            weekStartsOn: weekStartsOn,
            includeCurrentDay: false
        )
    }

    private static func completionCount(
        entries: [TrackingEntry],
        trackerID: UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday,
        includeCurrentDay: Bool
    ) -> Int {
        guard let bounds = weekBounds(containing: dayKey, weekStartsOn: weekStartsOn) else {
            return 0
        }

        return entries.filter { entry in
            guard entry.trackerId == trackerID else { return false }
            guard entry.dayKey >= bounds.start && entry.dayKey <= bounds.end else { return false }
            return includeCurrentDay ? entry.dayKey <= dayKey : entry.dayKey < dayKey
        }
        .count
    }

    private static func weekBounds(containing day: DayKey, weekStartsOn: MarkerWeekday) -> (start: DayKey, end: DayKey)? {
        guard let weekday = day.weekday else { return nil }
        let offset = (weekday.rawValue - weekStartsOn.rawValue + 7) % 7
        guard let start = day.addingDays(-offset),
              let end = start.addingDays(6) else {
            return nil
        }

        return (start, end)
    }

    private static func trackerCreatedDayKey(for tracker: Tracker) -> DayKey {
        DayKey(date: tracker.createdAt, timeZone: .current)
    }

    private static func key(trackerID: UUID, dayKey: DayKey) -> String {
        "\(trackerID.uuidString)|\(dayKey.rawValue)"
    }
}
