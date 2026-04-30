package com.edge.marker.domain

import java.util.Date
import java.util.UUID

enum class TrackerKind(
    val rawValue: String,
    val title: String,
) {
    HABIT(rawValue = "habit", title = "习惯"),
    MEDICATION(rawValue = "medication", title = "用药"),
    CYCLE(rawValue = "cycle", title = "经期"),
    CUSTOM(rawValue = "custom", title = "自定义"),
}

enum class MarkerWeekday(
    val rawValue: Int,
    val shortTitle: String,
) {
    SUNDAY(rawValue = 1, shortTitle = "周日"),
    MONDAY(rawValue = 2, shortTitle = "周一"),
    TUESDAY(rawValue = 3, shortTitle = "周二"),
    WEDNESDAY(rawValue = 4, shortTitle = "周三"),
    THURSDAY(rawValue = 5, shortTitle = "周四"),
    FRIDAY(rawValue = 6, shortTitle = "周五"),
    SATURDAY(rawValue = 7, shortTitle = "周六"),
    ;

    val calendarValue: Int
        get() = rawValue

    companion object {
        fun fromCalendarValue(value: Int): MarkerWeekday = entries.first { weekday: MarkerWeekday ->
            weekday.rawValue == value
        }
    }
}

sealed interface TrackerSchedule {
    fun isDue(on: DayKey, completedCountInWeek: Int = 0): Boolean = when (this) {
        Daily -> true
        is WeeklyOnDays -> days.contains(on.weekday)
        is WeeklyQuota -> completedCountInWeek < maxOf(targetCount, 1)
    }

    data object Daily : TrackerSchedule

    data class WeeklyOnDays(val days: Set<MarkerWeekday>) : TrackerSchedule

    data class WeeklyQuota(val targetCount: Int) : TrackerSchedule
}

data class LocalTime(
    val hour: Int,
    val minute: Int,
)

enum class HomeTabPreference(val title: String) {
    TODAY(title = "Today"),
    HISTORY(title = "History"),
    STATISTICS(title = "Statistics"),
    SETTINGS(title = "Settings"),
}

enum class StatisticsWindow(
    val dayCount: Int,
    val title: String,
) {
    SEVEN_DAYS(dayCount = 7, title = "近 7 天"),
    THIRTY_DAYS(dayCount = 30, title = "近 30 天"),
    NINETY_DAYS(dayCount = 90, title = "近 90 天"),
}

data class Tracker(
    val id: UUID,
    val kind: TrackerKind = TrackerKind.HABIT,
    val name: String,
    val colorToken: String,
    val notes: String,
    val schedule: TrackerSchedule,
    val isArchived: Boolean,
    val createdAt: Date,
    val updatedAt: Date,
)

data class TrackingEntry(
    val id: UUID,
    val trackerId: UUID,
    val dayKey: DayKey,
    val recordedAt: Date,
    val recordedTimeZoneIdentifier: String,
)

data class TrackerReminder(
    val id: UUID,
    val trackerId: UUID,
    val localTime: LocalTime,
    val weekdays: Set<MarkerWeekday>,
    val isEnabled: Boolean,
)

data class UserPreference(
    val weekStartsOn: MarkerWeekday,
    val defaultHomeTab: HomeTabPreference,
    val preferredStatisticsWindow: StatisticsWindow,
) {
    companion object {
        val defaultValue: UserPreference = UserPreference(
            weekStartsOn = MarkerWeekday.MONDAY,
            defaultHomeTab = HomeTabPreference.TODAY,
            preferredStatisticsWindow = StatisticsWindow.THIRTY_DAYS,
        )
    }
}
