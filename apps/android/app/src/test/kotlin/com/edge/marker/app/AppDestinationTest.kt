package com.edge.marker.app

import org.junit.Assert.assertEquals
import org.junit.Test

class AppDestinationTest {
    @Test
    fun topLevelDestinationsExposeExpectedTitlesInOrder() {
        assertEquals(
            listOf("Today", "History", "Statistics", "Settings"),
            AppDestination.entries.map(AppDestination::title),
        )
    }

    @Test
    fun topLevelDestinationsExposeExpectedRoutesInOrder() {
        assertEquals(
            listOf("today", "history", "statistics", "settings"),
            AppDestination.entries.map(AppDestination::route),
        )
    }
}
