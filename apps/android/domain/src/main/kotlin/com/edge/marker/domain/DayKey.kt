package com.edge.marker.domain

import java.util.Calendar
import java.util.Date
import java.util.GregorianCalendar
import java.util.TimeZone

data class DayKey(val rawValue: String) : Comparable<DayKey> {
    constructor(year: Int, month: Int, day: Int) : this(format(year = year, month = month, day = day))

    constructor(
        date: Date,
        timeZone: TimeZone,
        calendar: Calendar = GregorianCalendar(),
    ) : this(
        year = calendar.copyWith(timeZone = timeZone).run {
            time = date
            get(Calendar.YEAR)
        },
        month = calendar.copyWith(timeZone = timeZone).run {
            time = date
            get(Calendar.MONTH) + 1
        },
        day = calendar.copyWith(timeZone = timeZone).run {
            time = date
            get(Calendar.DAY_OF_MONTH)
        },
    )

    init {
        val parts: List<String> = rawValue.split("-")
        require(parts.size == 3) { "dayKey must be formatted as YYYY-MM-DD" }

        val year: Int = parts[0].toIntOrNull() ?: error("dayKey year is invalid")
        val month: Int = parts[1].toIntOrNull() ?: error("dayKey month is invalid")
        val day: Int = parts[2].toIntOrNull() ?: error("dayKey day is invalid")

        val normalized: String = format(year = year, month = month, day = day)
        require(rawValue == normalized) { "dayKey must use canonical zero-padded format" }

        val utcCalendar: Calendar = utcCalendar()
        utcCalendar.isLenient = false
        utcCalendar.set(year, month - 1, day, 0, 0, 0)
        utcCalendar.set(Calendar.MILLISECOND, 0)
        utcCalendar.time
    }

    val date: Date
        get() = utcCalendar().run {
            val (year, month, day) = parseComponents(rawValue = rawValue)
            set(year, month - 1, day, 0, 0, 0)
            set(Calendar.MILLISECOND, 0)
            time
        }

    val weekday: MarkerWeekday
        get() = MarkerWeekday.fromCalendarValue(
            value = utcCalendar().run {
                time = date
                get(Calendar.DAY_OF_WEEK)
            },
        )

    fun addingDays(days: Int): DayKey {
        val utcCalendar: Calendar = utcCalendar()
        utcCalendar.time = date
        utcCalendar.add(Calendar.DAY_OF_MONTH, days)

        return DayKey(
            date = utcCalendar.time,
            timeZone = UTC_TIME_ZONE,
            calendar = utcCalendar,
        )
    }

    override fun compareTo(other: DayKey): Int = rawValue.compareTo(other.rawValue)

    override fun toString(): String = rawValue

    companion object {
        private val UTC_TIME_ZONE: TimeZone = TimeZone.getTimeZone("UTC")

        private fun format(year: Int, month: Int, day: Int): String = "%04d-%02d-%02d".format(year, month, day)

        private fun parseComponents(rawValue: String): Triple<Int, Int, Int> {
            val parts: List<String> = rawValue.split("-")

            return Triple(
                first = parts[0].toInt(),
                second = parts[1].toInt(),
                third = parts[2].toInt(),
            )
        }

        private fun utcCalendar(): Calendar = GregorianCalendar(UTC_TIME_ZONE)
    }
}

private fun Calendar.copyWith(timeZone: TimeZone): Calendar {
    val copy: Calendar = (clone() as Calendar)
    copy.timeZone = timeZone
    copy.isLenient = false
    return copy
}
