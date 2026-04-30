package com.edge.marker.domain

import java.util.Date
import java.util.UUID
import org.junit.Assert.assertEquals
import org.junit.Test

class TrackerContractTypesTest {
    @Test
    fun coreContractTypesCanBeConstructed() {
        val now = Date(1_776_096_000_000)
        val dayKey = DayKey(year = 2026, month = 4, day = 13)
        val schedule = TrackerSchedule.WeeklyQuota(targetCount = 3)
        val trackerId = UUID.randomUUID()

        val tracker = Tracker(
            id = trackerId,
            kind = TrackerKind.HABIT,
            name = "Read",
            colorToken = "blue",
            notes = "20 minutes",
            schedule = schedule,
            isArchived = false,
            createdAt = now,
            updatedAt = now,
        )
        val reminder = TrackerReminder(
            id = UUID.randomUUID(),
            trackerId = trackerId,
            localTime = LocalTime(hour = 8, minute = 30),
            weekdays = setOf(MarkerWeekday.MONDAY, MarkerWeekday.WEDNESDAY, MarkerWeekday.FRIDAY),
            isEnabled = true,
        )
        val entry = TrackingEntry(
            id = UUID.randomUUID(),
            trackerId = trackerId,
            dayKey = dayKey,
            recordedAt = now,
            recordedTimeZoneIdentifier = "Asia/Shanghai",
        )
        val preference = UserPreference(
            weekStartsOn = MarkerWeekday.MONDAY,
            defaultHomeTab = HomeTabPreference.TODAY,
            preferredStatisticsWindow = StatisticsWindow.THIRTY_DAYS,
        )

        assertEquals(schedule, tracker.schedule)
        assertEquals(8, reminder.localTime.hour)
        assertEquals(dayKey, entry.dayKey)
        assertEquals(HomeTabPreference.TODAY, preference.defaultHomeTab)
    }
}
