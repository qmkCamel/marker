package com.edge.marker.data

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import com.edge.marker.domain.DayKey
import com.edge.marker.domain.HomeTabPreference
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.StatisticsWindow
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackerKind
import com.edge.marker.domain.TrackerSchedule
import com.edge.marker.domain.TrackingEntry
import com.edge.marker.domain.UserPreference
import java.util.Date
import java.util.UUID

@Entity(tableName = "trackers")
data class TrackerEntity(
    @PrimaryKey val id: String,
    val kind: String,
    val name: String,
    val colorToken: String,
    val notes: String,
    val scheduleType: String,
    val scheduleWeekdays: String?,
    val scheduleTargetCount: Int?,
    val isArchived: Boolean,
    val createdAtMillis: Long,
    val updatedAtMillis: Long,
) {
    fun toDomain(): Tracker = Tracker(
        id = UUID.fromString(id),
        kind = TrackerKind.entries.firstOrNull { trackerKind: TrackerKind -> trackerKind.rawValue == kind } ?: TrackerKind.CUSTOM,
        name = name,
        colorToken = colorToken,
        notes = notes,
        schedule = decodeSchedule(
            scheduleType = scheduleType,
            scheduleWeekdays = scheduleWeekdays,
            scheduleTargetCount = scheduleTargetCount,
        ),
        isArchived = isArchived,
        createdAt = Date(createdAtMillis),
        updatedAt = Date(updatedAtMillis),
    )

    companion object {
        fun fromDomain(tracker: Tracker): TrackerEntity {
            val scheduleEncoding: ScheduleEncoding = encodeSchedule(schedule = tracker.schedule)

            return TrackerEntity(
                id = tracker.id.toString(),
                kind = tracker.kind.rawValue,
                name = tracker.name,
                colorToken = tracker.colorToken,
                notes = tracker.notes,
                scheduleType = scheduleEncoding.type,
                scheduleWeekdays = scheduleEncoding.weekdays,
                scheduleTargetCount = scheduleEncoding.targetCount,
                isArchived = tracker.isArchived,
                createdAtMillis = tracker.createdAt.time,
                updatedAtMillis = tracker.updatedAt.time,
            )
        }
    }
}

@Entity(
    tableName = "trackingEntries",
    foreignKeys = [
        ForeignKey(
            entity = TrackerEntity::class,
            parentColumns = ["id"],
            childColumns = ["trackerId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [Index(value = ["trackerId", "dayKey"], unique = true), Index(value = ["dayKey"])],
)
data class TrackingEntryEntity(
    @PrimaryKey val id: String,
    val trackerId: String,
    val dayKey: String,
    val recordedAtMillis: Long,
    val recordedTimeZoneIdentifier: String,
) {
    fun toDomain(): TrackingEntry = TrackingEntry(
        id = UUID.fromString(id),
        trackerId = UUID.fromString(trackerId),
        dayKey = DayKey(dayKey),
        recordedAt = Date(recordedAtMillis),
        recordedTimeZoneIdentifier = recordedTimeZoneIdentifier,
    )

    companion object {
        fun fromDomain(entry: TrackingEntry): TrackingEntryEntity = TrackingEntryEntity(
            id = entry.id.toString(),
            trackerId = entry.trackerId.toString(),
            dayKey = entry.dayKey.rawValue,
            recordedAtMillis = entry.recordedAt.time,
            recordedTimeZoneIdentifier = entry.recordedTimeZoneIdentifier,
        )
    }
}

@Entity(tableName = "userPreferences")
data class UserPreferenceEntity(
    @PrimaryKey val singletonKey: Int = 1,
    val weekStartsOn: Int,
    val defaultHomeTab: String,
    val preferredStatisticsWindow: String,
) {
    fun toDomain(): UserPreference = UserPreference(
        weekStartsOn = MarkerWeekday.entries.first { weekday: MarkerWeekday -> weekday.rawValue == weekStartsOn },
        defaultHomeTab = HomeTabPreference.valueOf(defaultHomeTab),
        preferredStatisticsWindow = StatisticsWindow.valueOf(preferredStatisticsWindow),
    )

    companion object {
        fun fromDomain(preference: UserPreference): UserPreferenceEntity = UserPreferenceEntity(
            weekStartsOn = preference.weekStartsOn.rawValue,
            defaultHomeTab = preference.defaultHomeTab.name,
            preferredStatisticsWindow = preference.preferredStatisticsWindow.name,
        )
    }
}

private data class ScheduleEncoding(
    val type: String,
    val weekdays: String?,
    val targetCount: Int?,
)

private fun encodeSchedule(schedule: TrackerSchedule): ScheduleEncoding = when (schedule) {
    TrackerSchedule.Daily -> ScheduleEncoding(type = "daily", weekdays = null, targetCount = null)
    is TrackerSchedule.WeeklyOnDays -> ScheduleEncoding(
        type = "weeklyOnDays",
        weekdays = schedule.days
            .map(MarkerWeekday::rawValue)
            .sorted()
            .joinToString(separator = ","),
        targetCount = null,
    )
    is TrackerSchedule.WeeklyQuota -> ScheduleEncoding(
        type = "weeklyQuota",
        weekdays = null,
        targetCount = schedule.targetCount,
    )
}

private fun decodeSchedule(
    scheduleType: String,
    scheduleWeekdays: String?,
    scheduleTargetCount: Int?,
): TrackerSchedule = when (scheduleType) {
    "daily" -> TrackerSchedule.Daily
    "weeklyOnDays" -> TrackerSchedule.WeeklyOnDays(
        days = scheduleWeekdays
            ?.split(",")
            ?.filter(String::isNotBlank)
            ?.map { value: String -> MarkerWeekday.fromCalendarValue(value.toInt()) }
            ?.toSet()
            ?: emptySet(),
    )
    "weeklyQuota" -> TrackerSchedule.WeeklyQuota(targetCount = maxOf(scheduleTargetCount ?: 1, 1))
    else -> TrackerSchedule.Daily
}
