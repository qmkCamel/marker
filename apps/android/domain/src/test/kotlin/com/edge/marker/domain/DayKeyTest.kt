package com.edge.marker.domain

import java.util.Calendar
import java.util.GregorianCalendar
import java.util.TimeZone
import org.junit.Assert.assertEquals
import org.junit.Test

class DayKeyTest {
    @Test
    fun canonicalStringFormatRoundTrips() {
        val dayKey = DayKey(year = 2026, month = 4, day = 13)

        assertEquals("2026-04-13", dayKey.rawValue)
        assertEquals(dayKey, DayKey("2026-04-13"))
    }

    @Test
    fun dateUsesProvidedTimeZoneWhenDerivingDayKey() {
        val utc = TimeZone.getTimeZone("UTC")
        val calendar = GregorianCalendar(utc).apply {
            set(2026, Calendar.APRIL, 13, 17, 30, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val date = calendar.time
        val shanghai = TimeZone.getTimeZone("Asia/Shanghai")
        val losAngeles = TimeZone.getTimeZone("America/Los_Angeles")

        assertEquals("2026-04-14", DayKey(date = date, timeZone = shanghai).rawValue)
        assertEquals("2026-04-13", DayKey(date = date, timeZone = losAngeles).rawValue)
    }
}
