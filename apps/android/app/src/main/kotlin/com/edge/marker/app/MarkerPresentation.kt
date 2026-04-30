package com.edge.marker.app

import androidx.compose.ui.graphics.Color
import com.edge.marker.domain.TrackerSchedule

object MarkerPresentation {
    fun color(token: String): Color = when (token) {
        "blue" -> Color.Blue
        "green" -> Color(0xFF2E7D32)
        "orange" -> Color(0xFFEF6C00)
        "pink" -> Color(0xFFD81B60)
        "purple" -> Color(0xFF8E24AA)
        "teal" -> Color(0xFF00897B)
        "red" -> Color(0xFFC62828)
        else -> Color(0xFF6750A4)
    }

    fun scheduleDescription(schedule: TrackerSchedule): String = when (schedule) {
        TrackerSchedule.Daily -> "每天"
        is TrackerSchedule.WeeklyOnDays -> schedule.days
            .sortedBy { weekday -> weekday.rawValue }
            .joinToString(separator = "、") { weekday -> weekday.shortTitle }
        is TrackerSchedule.WeeklyQuota -> "每周 ${schedule.targetCount} 次"
    }
}
