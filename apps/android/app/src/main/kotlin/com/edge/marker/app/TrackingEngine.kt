package com.edge.marker.app

import com.edge.marker.domain.DayKey
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackerSchedule
import com.edge.marker.domain.TrackingEntry
import com.edge.marker.domain.UserPreference
import java.util.TimeZone
import java.util.UUID

data class TodayTrackerItem(
    val tracker: Tracker,
    val isCompleted: Boolean,
    val weeklyProgressText: String?,
) {
    val id: UUID
        get() = tracker.id
}

data class HistoryDayItem(
    val trackerName: String,
    val colorToken: String,
    val recordedAtMillis: Long,
) {
    val id: String
        get() = "$trackerName-$recordedAtMillis"
}

data class HistoryDaySection(
    val dayKey: DayKey,
    val items: List<HistoryDayItem>,
) {
    val id: String
        get() = dayKey.rawValue
}

data class TrackerCompletionSummary(
    val trackerId: UUID,
    val trackerName: String,
    val colorToken: String,
    val totalEntryCount: Int,
) {
    val id: UUID
        get() = trackerId
}

data class StatisticsSummary(
    val activeTrackerCount: Int,
    val totalEntryCount: Int,
    val currentWindowCompletedCount: Int,
    val currentWindowDueCount: Int,
    val currentWindowCompletionRate: Double,
    val currentStreakDays: Int,
    val trackerBreakdown: List<TrackerCompletionSummary>,
)

object TrackingEngine {
    fun buildTodayItems(
        trackers: List<Tracker>,
        entries: List<TrackingEntry>,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday,
    ): List<TodayTrackerItem> {
        val activeTrackers: List<Tracker> = trackers.filter { tracker -> !tracker.isArchived }
        val completedKeys: Set<String> = entries.mapTo(mutableSetOf()) { entry ->
            key(trackerId = entry.trackerId, dayKey = entry.dayKey)
        }

        return activeTrackers.mapNotNull { tracker ->
            val completedCount: Int = completionCountBeforeOrOnDay(
                entries = entries,
                trackerId = tracker.id,
                dayKey = dayKey,
                weekStartsOn = weekStartsOn,
            )
            val isDue: Boolean = tracker.schedule.isDue(on = dayKey, completedCountInWeek = completedCount)

            if (!isDue) {
                null
            } else {
                TodayTrackerItem(
                    tracker = tracker,
                    isCompleted = completedKeys.contains(key(trackerId = tracker.id, dayKey = dayKey)),
                    weeklyProgressText = when (val schedule = tracker.schedule) {
                        is TrackerSchedule.WeeklyQuota -> "${minOf(completedCount, schedule.targetCount)}/${schedule.targetCount}"
                        else -> null
                    },
                )
            }
        }.sortedBy { item -> item.tracker.createdAt }
    }

    fun buildHistorySections(
        trackers: List<Tracker>,
        entries: List<TrackingEntry>,
    ): List<HistoryDaySection> {
        val trackerLookup: Map<UUID, Tracker> = trackers.associateBy { tracker -> tracker.id }

        return entries
            .groupBy { entry -> entry.dayKey }
            .toSortedMap(reverseOrder())
            .map { (dayKey, groupedEntries) ->
                HistoryDaySection(
                    dayKey = dayKey,
                    items = groupedEntries
                        .sortedByDescending { entry -> entry.recordedAt.time }
                        .mapNotNull { entry ->
                            trackerLookup[entry.trackerId]?.let { tracker ->
                                HistoryDayItem(
                                    trackerName = tracker.name,
                                    colorToken = tracker.colorToken,
                                    recordedAtMillis = entry.recordedAt.time,
                                )
                            }
                        },
                )
            }
            .filter { section -> section.items.isNotEmpty() }
    }

    fun buildStatisticsSummary(
        trackers: List<Tracker>,
        entries: List<TrackingEntry>,
        today: DayKey,
        preferences: UserPreference,
    ): StatisticsSummary {
        val activeTrackers: List<Tracker> = trackers.filter { tracker -> !tracker.isArchived }
        val completedKeys: Set<String> = entries.mapTo(mutableSetOf()) { entry ->
            key(trackerId = entry.trackerId, dayKey = entry.dayKey)
        }
        val windowStart: DayKey = today.addingDays(days = -(preferences.preferredStatisticsWindow.dayCount - 1))

        var dueCount = 0
        var completedCount = 0
        var currentDay: DayKey = windowStart

        while (currentDay <= today) {
            activeTrackers
                .filter { tracker -> trackerCreatedDayKey(tracker = tracker) <= currentDay }
                .forEach { tracker ->
                    val weeklyCountBeforeDay: Int = completionCountBeforeDay(
                        entries = entries,
                        trackerId = tracker.id,
                        dayKey = currentDay,
                        weekStartsOn = preferences.weekStartsOn,
                    )

                    if (tracker.schedule.isDue(on = currentDay, completedCountInWeek = weeklyCountBeforeDay)) {
                        dueCount += 1
                        if (completedKeys.contains(key(trackerId = tracker.id, dayKey = currentDay))) {
                            completedCount += 1
                        }
                    }
                }

            if (currentDay == today) {
                break
            }
            currentDay = currentDay.addingDays(days = 1)
        }

        val trackerBreakdown: List<TrackerCompletionSummary> = activeTrackers
            .map { tracker ->
                TrackerCompletionSummary(
                    trackerId = tracker.id,
                    trackerName = tracker.name,
                    colorToken = tracker.colorToken,
                    totalEntryCount = entries.count { entry -> entry.trackerId == tracker.id },
                )
            }
            .sortedWith(
                compareByDescending<TrackerCompletionSummary> { summary -> summary.totalEntryCount }
                    .thenBy { summary -> summary.trackerName },
            )

        return StatisticsSummary(
            activeTrackerCount = activeTrackers.count(),
            totalEntryCount = entries.count(),
            currentWindowCompletedCount = completedCount,
            currentWindowDueCount = dueCount,
            currentWindowCompletionRate = if (dueCount == 0) 0.0 else completedCount.toDouble() / dueCount.toDouble(),
            currentStreakDays = buildCurrentStreakDays(entries = entries, today = today),
            trackerBreakdown = trackerBreakdown,
        )
    }

    private fun buildCurrentStreakDays(entries: List<TrackingEntry>, today: DayKey): Int {
        val completedDays: Set<DayKey> = entries.mapTo(mutableSetOf()) { entry -> entry.dayKey }
        var streak = 0
        var cursor: DayKey = today

        while (completedDays.contains(cursor)) {
            streak += 1
            cursor = cursor.addingDays(days = -1)
        }

        return streak
    }

    private fun completionCountBeforeOrOnDay(
        entries: List<TrackingEntry>,
        trackerId: UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday,
    ): Int = completionCount(
        entries = entries,
        trackerId = trackerId,
        dayKey = dayKey,
        weekStartsOn = weekStartsOn,
        includeCurrentDay = true,
    )

    private fun completionCountBeforeDay(
        entries: List<TrackingEntry>,
        trackerId: UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday,
    ): Int = completionCount(
        entries = entries,
        trackerId = trackerId,
        dayKey = dayKey,
        weekStartsOn = weekStartsOn,
        includeCurrentDay = false,
    )

    private fun completionCount(
        entries: List<TrackingEntry>,
        trackerId: UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday,
        includeCurrentDay: Boolean,
    ): Int {
        val bounds: WeekBounds = weekBounds(dayKey = dayKey, weekStartsOn = weekStartsOn)

        return entries.count { entry ->
            entry.trackerId == trackerId &&
                entry.dayKey >= bounds.start &&
                entry.dayKey <= bounds.end &&
                if (includeCurrentDay) entry.dayKey <= dayKey else entry.dayKey < dayKey
        }
    }

    private fun weekBounds(dayKey: DayKey, weekStartsOn: MarkerWeekday): WeekBounds {
        val offset: Int = (dayKey.weekday.rawValue - weekStartsOn.rawValue + 7) % 7
        val start: DayKey = dayKey.addingDays(days = -offset)
        val end: DayKey = start.addingDays(days = 6)
        return WeekBounds(start = start, end = end)
    }

    private fun key(trackerId: UUID, dayKey: DayKey): String = "${trackerId}|${dayKey.rawValue}"

    private fun trackerCreatedDayKey(tracker: Tracker): DayKey = DayKey(
        date = tracker.createdAt,
        timeZone = TimeZone.getDefault(),
    )
}

private data class WeekBounds(
    val start: DayKey,
    val end: DayKey,
)
