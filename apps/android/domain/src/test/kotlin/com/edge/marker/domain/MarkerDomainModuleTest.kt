package com.edge.marker.domain

import org.junit.Assert.assertEquals
import org.junit.Test

class MarkerDomainModuleTest {
    @Test
    fun defaultBoundariesExposeExpectedValuesInOrder() {
        assertEquals(
            listOf(
                MarkerDomainBoundary.TRACKER_REPOSITORY,
                MarkerDomainBoundary.TRACKING_ENTRY_REPOSITORY,
                MarkerDomainBoundary.STATISTICS_REPOSITORY,
                MarkerDomainBoundary.TRACKER_REMINDER_SCHEDULER,
            ),
            MarkerDomainModule.defaultBoundaries,
        )
    }

    @Test
    fun userPreferenceDefaultValueMatchesExpectedDefaults() {
        assertEquals(MarkerWeekday.MONDAY, UserPreference.defaultValue.weekStartsOn)
        assertEquals(HomeTabPreference.TODAY, UserPreference.defaultValue.defaultHomeTab)
        assertEquals(StatisticsWindow.THIRTY_DAYS, UserPreference.defaultValue.preferredStatisticsWindow)
    }
}
