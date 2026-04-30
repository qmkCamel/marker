package com.edge.marker.app

import androidx.test.core.app.ApplicationProvider
import com.edge.marker.data.MarkerLocalStore
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackerKind
import com.edge.marker.domain.TrackerSchedule
import com.edge.marker.domain.TrackingEntry
import com.edge.marker.domain.StatisticsWindow
import java.util.Date
import java.util.TimeZone
import java.util.UUID
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MarkerAppModelTest {
    private lateinit var store: MarkerLocalStore
    private val now = Date(1_776_096_000_000)
    private val shanghai = TimeZone.getTimeZone("Asia/Shanghai")

    @Before
    fun setUp() {
        store = MarkerLocalStore.inMemory(context = ApplicationProvider.getApplicationContext())
    }

    @After
    fun tearDown() {
        store.close()
    }

    @Test
    fun toggleEntryCreatesAndRemovesTodayEntry() {
        val tracker = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.HABIT,
            name = "Read",
            colorToken = "blue",
            notes = "",
            schedule = TrackerSchedule.Daily,
            isArchived = false,
            createdAt = now,
            updatedAt = now,
        )
        store.saveTracker(tracker)

        val model = MarkerAppModel(
            store = store,
            nowProvider = { now },
            timeZoneProvider = { shanghai },
        )

        model.toggleEntry(tracker)
        assertEquals(1, model.entries.size)
        assertNotNull(store.fetchEntry(trackerId = tracker.id, dayKey = model.todayKey))

        model.toggleEntry(tracker)
        assertEquals(0, model.entries.size)
        assertEquals(null, store.fetchEntry(trackerId = tracker.id, dayKey = model.todayKey))
    }

    @Test
    fun updatesPreferencesAndRestoresArchivedTrackers() {
        val archivedTracker = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.CUSTOM,
            name = "Archive Me",
            colorToken = "purple",
            notes = "",
            schedule = TrackerSchedule.Daily,
            isArchived = true,
            createdAt = now,
            updatedAt = now,
        )
        store.saveTracker(archivedTracker)

        val model = MarkerAppModel(
            store = store,
            nowProvider = { now },
            timeZoneProvider = { shanghai },
        )

        model.updateWeekStartsOn(MarkerWeekday.SUNDAY)
        model.updateStatisticsWindow(StatisticsWindow.NINETY_DAYS)
        model.restoreTracker(archivedTracker)

        assertEquals(MarkerWeekday.SUNDAY, model.preferences.weekStartsOn)
        assertEquals(StatisticsWindow.NINETY_DAYS, model.preferences.preferredStatisticsWindow)
        assertEquals(0, model.archivedTrackers.size)
    }
}
