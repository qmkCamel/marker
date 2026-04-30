package com.edge.marker.app

import org.junit.Assert.assertEquals
import org.junit.Test

class TrackerDraftTest {
    @Test
    fun emptyNameIsInvalid() {
        val draft = TrackerDraft.empty.copy(name = "   ")

        assertEquals("请输入追踪项名称", draft.validationMessage)
    }

    @Test
    fun weeklyOnDaysRequiresAtLeastOneWeekday() {
        val draft = TrackerDraft.empty.copy(
            name = "Workout",
            scheduleKind = TrackerScheduleKind.WEEKLY_ON_DAYS,
            selectedWeekdays = emptySet(),
        )

        assertEquals("请选择至少一个星期", draft.validationMessage)
    }

    @Test
    fun weeklyQuotaRequiresPositiveTarget() {
        val draft = TrackerDraft.empty.copy(
            name = "Read",
            scheduleKind = TrackerScheduleKind.WEEKLY_QUOTA,
            weeklyQuotaTarget = 0,
        )

        assertEquals("每周目标次数必须大于 0", draft.validationMessage)
    }
}
