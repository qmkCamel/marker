package com.edge.marker.app

import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackerKind
import com.edge.marker.domain.TrackerSchedule
import java.util.Date
import java.util.UUID

enum class TrackerScheduleKind(val title: String) {
    DAILY(title = "每天"),
    WEEKLY_ON_DAYS(title = "按星期"),
    WEEKLY_QUOTA(title = "每周次数"),
}

data class TrackerDraft(
    val id: UUID,
    val existingTrackerId: UUID?,
    val createdAt: Date,
    val kind: TrackerKind,
    val name: String,
    val colorToken: String,
    val notes: String,
    val scheduleKind: TrackerScheduleKind,
    val selectedWeekdays: Set<MarkerWeekday>,
    val weeklyQuotaTarget: Int,
    val isArchived: Boolean,
) {
    constructor(tracker: Tracker) : this(
        id = tracker.id,
        existingTrackerId = tracker.id,
        createdAt = tracker.createdAt,
        kind = tracker.kind,
        name = tracker.name,
        colorToken = tracker.colorToken,
        notes = tracker.notes,
        scheduleKind = when (tracker.schedule) {
            TrackerSchedule.Daily -> TrackerScheduleKind.DAILY
            is TrackerSchedule.WeeklyOnDays -> TrackerScheduleKind.WEEKLY_ON_DAYS
            is TrackerSchedule.WeeklyQuota -> TrackerScheduleKind.WEEKLY_QUOTA
        },
        selectedWeekdays = when (val schedule = tracker.schedule) {
            TrackerSchedule.Daily -> setOf(MarkerWeekday.MONDAY, MarkerWeekday.WEDNESDAY, MarkerWeekday.FRIDAY)
            is TrackerSchedule.WeeklyOnDays -> schedule.days
            is TrackerSchedule.WeeklyQuota -> setOf(MarkerWeekday.MONDAY, MarkerWeekday.WEDNESDAY, MarkerWeekday.FRIDAY)
        },
        weeklyQuotaTarget = when (val schedule = tracker.schedule) {
            TrackerSchedule.Daily -> 3
            is TrackerSchedule.WeeklyOnDays -> 3
            is TrackerSchedule.WeeklyQuota -> schedule.targetCount
        },
        isArchived = tracker.isArchived,
    )

    val validationMessage: String?
        get() {
            if (name.trim().isEmpty()) {
                return "请输入追踪项名称"
            }

            return when {
                scheduleKind == TrackerScheduleKind.WEEKLY_ON_DAYS && selectedWeekdays.isEmpty() -> "请选择至少一个星期"
                scheduleKind == TrackerScheduleKind.WEEKLY_QUOTA && weeklyQuotaTarget <= 0 -> "每周目标次数必须大于 0"
                else -> null
            }
        }

    fun makeTracker(updatedAt: Date = Date()): Tracker = Tracker(
        id = existingTrackerId ?: id,
        kind = kind,
        name = name.trim(),
        colorToken = colorToken,
        notes = notes.trim(),
        schedule = schedule,
        isArchived = isArchived,
        createdAt = createdAt,
        updatedAt = updatedAt,
    )

    private val schedule: TrackerSchedule
        get() = when (scheduleKind) {
            TrackerScheduleKind.DAILY -> TrackerSchedule.Daily
            TrackerScheduleKind.WEEKLY_ON_DAYS -> TrackerSchedule.WeeklyOnDays(days = selectedWeekdays)
            TrackerScheduleKind.WEEKLY_QUOTA -> TrackerSchedule.WeeklyQuota(targetCount = maxOf(weeklyQuotaTarget, 1))
        }

    companion object {
        val availableColorTokens: List<String> = listOf("blue", "green", "orange", "pink", "purple", "teal", "red")

        val empty: TrackerDraft = TrackerDraft(
            id = UUID.randomUUID(),
            existingTrackerId = null,
            createdAt = Date(),
            kind = TrackerKind.HABIT,
            name = "",
            colorToken = "blue",
            notes = "",
            scheduleKind = TrackerScheduleKind.DAILY,
            selectedWeekdays = setOf(MarkerWeekday.MONDAY, MarkerWeekday.WEDNESDAY, MarkerWeekday.FRIDAY),
            weeklyQuotaTarget = 3,
            isArchived = false,
        )
    }
}
