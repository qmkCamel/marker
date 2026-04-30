package com.edge.marker.domain

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TrackerScheduleTest {
    @Test
    fun dailyScheduleIsDueOnAnyDay() {
        val monday = DayKey(year = 2026, month = 4, day = 13)

        assertTrue(TrackerSchedule.Daily.isDue(on = monday))
    }

    @Test
    fun weeklyOnDaysIsDueOnlyOnSelectedWeekdays() {
        val monday = DayKey(year = 2026, month = 4, day = 13)
        val tuesday = DayKey(year = 2026, month = 4, day = 14)
        val schedule = TrackerSchedule.WeeklyOnDays(setOf(MarkerWeekday.MONDAY, MarkerWeekday.WEDNESDAY, MarkerWeekday.FRIDAY))

        assertTrue(schedule.isDue(on = monday))
        assertFalse(schedule.isDue(on = tuesday))
    }

    @Test
    fun weeklyQuotaRemainsDueUntilTargetReached() {
        val monday = DayKey(year = 2026, month = 4, day = 13)
        val schedule = TrackerSchedule.WeeklyQuota(targetCount = 3)

        assertTrue(schedule.isDue(on = monday, completedCountInWeek = 0))
        assertTrue(schedule.isDue(on = monday, completedCountInWeek = 2))
    }

    @Test
    fun weeklyQuotaStopsBeingDueAfterQuotaIsSatisfied() {
        val monday = DayKey(year = 2026, month = 4, day = 13)
        val schedule = TrackerSchedule.WeeklyQuota(targetCount = 3)

        assertFalse(schedule.isDue(on = monday, completedCountInWeek = 3))
    }
}
