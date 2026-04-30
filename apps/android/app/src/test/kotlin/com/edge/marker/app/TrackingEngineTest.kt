package com.edge.marker.app

import com.edge.marker.domain.DayKey
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackerKind
import com.edge.marker.domain.TrackerSchedule
import com.edge.marker.domain.TrackingEntry
import com.edge.marker.domain.UserPreference
import java.util.Date
import java.util.UUID
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class TrackingEngineTest {
    @Test
    fun buildTodayItemsIncludesOnlyDueActiveTrackers() {
        val now = Date(1_776_096_000_000)
        val today = DayKey(year = 2026, month = 4, day = 13)
        val activeDaily = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.HABIT,
            name = "Read",
            colorToken = "blue",
            notes = "",
            schedule = TrackerSchedule.Daily,
            isArchived = false,
            createdAt = now,
            updatedAt = now,
        )
        val activeMonday = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.HABIT,
            name = "Workout",
            colorToken = "green",
            notes = "",
            schedule = TrackerSchedule.WeeklyOnDays(setOf(MarkerWeekday.MONDAY)),
            isArchived = false,
            createdAt = now,
            updatedAt = now,
        )
        val inactiveTuesday = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.CUSTOM,
            name = "Call Mom",
            colorToken = "pink",
            notes = "",
            schedule = TrackerSchedule.WeeklyOnDays(setOf(MarkerWeekday.TUESDAY)),
            isArchived = false,
            createdAt = now,
            updatedAt = now,
        )
        val archived = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.HABIT,
            name = "Archive Me",
            colorToken = "red",
            notes = "",
            schedule = TrackerSchedule.Daily,
            isArchived = true,
            createdAt = now,
            updatedAt = now,
        )

        val items = TrackingEngine.buildTodayItems(
            trackers = listOf(activeDaily, activeMonday, inactiveTuesday, archived),
            entries = emptyList(),
            dayKey = today,
            weekStartsOn = MarkerWeekday.MONDAY,
        )

        assertEquals(listOf(activeDaily.id, activeMonday.id), items.map(TodayTrackerItem::id))
    }

    @Test
    fun buildStatisticsSummaryReflectsCurrentWindow() {
        val now = Date(1_776_096_000_000)
        val today = DayKey(year = 2026, month = 4, day = 13)
        val yesterday = DayKey(year = 2026, month = 4, day = 12)
        val tracker = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.HABIT,
            name = "Read",
            colorToken = "blue",
            notes = "",
            schedule = TrackerSchedule.Daily,
            isArchived = false,
            createdAt = yesterday.date,
            updatedAt = now,
        )

        val summary = TrackingEngine.buildStatisticsSummary(
            trackers = listOf(tracker),
            entries = listOf(
                TrackingEntry(
                    id = UUID.randomUUID(),
                    trackerId = tracker.id,
                    dayKey = today,
                    recordedAt = now,
                    recordedTimeZoneIdentifier = "Asia/Shanghai",
                ),
                TrackingEntry(
                    id = UUID.randomUUID(),
                    trackerId = tracker.id,
                    dayKey = yesterday,
                    recordedAt = Date(now.time - 86_400_000),
                    recordedTimeZoneIdentifier = "Asia/Shanghai",
                ),
            ),
            today = today,
            preferences = UserPreference.defaultValue,
        )

        assertEquals(1, summary.activeTrackerCount)
        assertEquals(2, summary.totalEntryCount)
        assertTrue(summary.currentWindowCompletionRate > 0)
    }
}
