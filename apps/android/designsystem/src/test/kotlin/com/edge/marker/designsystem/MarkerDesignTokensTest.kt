package com.edge.marker.designsystem

import org.junit.Assert.assertEquals
import org.junit.Test

class MarkerDesignTokensTest {
    @Test
    fun spacingTokenMatchesIosBaseline() {
        assertEquals(24f, MarkerSpacing.ScreenPadding.value, 0f)
    }

    @Test
    fun cornerRadiusTokenMatchesIosBaseline() {
        assertEquals(20f, MarkerCornerRadius.Card.value, 0f)
    }
}
