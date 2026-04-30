package com.edge.marker.data

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import androidx.test.core.app.ApplicationProvider
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
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MarkerLocalStoreTest {
    private val context: Context = ApplicationProvider.getApplicationContext()
    private lateinit var store: MarkerLocalStore

    @Before
    fun setUp() {
        store = MarkerLocalStore.inMemory(context = context)
    }

    @After
    fun tearDown() {
        store.close()
    }

    @Test
    fun savingTrackerPersistsAndSeparatesArchivedFromActive() {
        val now = Date(1_776_096_000_000)
        val activeTracker = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.HABIT,
            name = "Read",
            colorToken = "blue",
            notes = "20 minutes",
            schedule = TrackerSchedule.Daily,
            isArchived = false,
            createdAt = now,
            updatedAt = now,
        )
        val archivedTracker = Tracker(
            id = UUID.randomUUID(),
            kind = TrackerKind.CUSTOM,
            name = "Walk",
            colorToken = "green",
            notes = "",
            schedule = TrackerSchedule.Daily,
            isArchived = true,
            createdAt = now,
            updatedAt = now,
        )

        store.saveTracker(activeTracker)
        store.saveTracker(archivedTracker)

        assertEquals(listOf(activeTracker.id), store.fetchActiveTrackers().map(Tracker::id))
        assertEquals(listOf(archivedTracker.id), store.fetchArchivedTrackers().map(Tracker::id))
    }

    @Test
    fun trackingEntryQueriesUseDayKeyAndWeeklyEntryCount() {
        val trackerId = UUID.randomUUID()
        val monday = DayKey(year = 2026, month = 4, day = 13)
        val wednesday = DayKey(year = 2026, month = 4, day = 15)
        val nextWeekMonday = DayKey(year = 2026, month = 4, day = 20)
        val now = Date(1_776_096_000_000)

        store.saveTracker(
            Tracker(
                id = trackerId,
                kind = TrackerKind.HABIT,
                name = "Workout",
                colorToken = "orange",
                notes = "",
                schedule = TrackerSchedule.WeeklyQuota(targetCount = 3),
                isArchived = false,
                createdAt = now,
                updatedAt = now,
            ),
        )

        store.saveEntry(
            TrackingEntry(
                id = UUID.randomUUID(),
                trackerId = trackerId,
                dayKey = monday,
                recordedAt = now,
                recordedTimeZoneIdentifier = "Asia/Shanghai",
            ),
        )
        store.saveEntry(
            TrackingEntry(
                id = UUID.randomUUID(),
                trackerId = trackerId,
                dayKey = wednesday,
                recordedAt = Date(now.time + 86_400_000),
                recordedTimeZoneIdentifier = "Asia/Shanghai",
            ),
        )
        store.saveEntry(
            TrackingEntry(
                id = UUID.randomUUID(),
                trackerId = trackerId,
                dayKey = nextWeekMonday,
                recordedAt = Date(now.time + 7 * 86_400_000),
                recordedTimeZoneIdentifier = "Asia/Shanghai",
            ),
        )

        assertEquals(1, store.fetchEntries(dayKey = monday).size)
        assertEquals(
            2,
            store.fetchWeeklyEntryCount(
                trackerId = trackerId,
                dayKey = wednesday,
                weekStartsOn = MarkerWeekday.MONDAY,
            ),
        )
        assertEquals(
            1,
            store.fetchWeeklyEntryCount(
                trackerId = trackerId,
                dayKey = nextWeekMonday,
                weekStartsOn = MarkerWeekday.MONDAY,
            ),
        )

        store.deleteEntry(trackerId = trackerId, dayKey = monday)

        assertEquals(0, store.fetchEntries(dayKey = monday).size)
        assertNotNull(store.fetchEntry(trackerId = trackerId, dayKey = wednesday))
    }

    @Test
    fun savingPreferencesPersistsLatestValues() {
        store.savePreferences(
            UserPreference(
                weekStartsOn = MarkerWeekday.SUNDAY,
                defaultHomeTab = HomeTabPreference.STATISTICS,
                preferredStatisticsWindow = StatisticsWindow.NINETY_DAYS,
            ),
        )

        val preferences: UserPreference? = store.fetchPreferences()

        assertNotNull(preferences)
        assertEquals(MarkerWeekday.SUNDAY, preferences?.weekStartsOn)
        assertEquals(HomeTabPreference.STATISTICS, preferences?.defaultHomeTab)
        assertEquals(StatisticsWindow.NINETY_DAYS, preferences?.preferredStatisticsWindow)
    }

    @Test
    fun migratesLegacyHabitSchemaToTrackerSchema() {
        val databaseName = "marker-legacy-migration.db"
        context.deleteDatabase(databaseName)

        val databasePath = context.getDatabasePath(databaseName)
        databasePath.parentFile?.mkdirs()
        val legacyDatabase = SQLiteDatabase.openOrCreateDatabase(databasePath, null)
        legacyDatabase.execSQL(
            """
            CREATE TABLE habits (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                colorToken TEXT NOT NULL,
                notes TEXT NOT NULL,
                scheduleType TEXT NOT NULL,
                scheduleWeekdays TEXT,
                scheduleTargetCount INTEGER,
                isArchived INTEGER NOT NULL,
                createdAtMillis INTEGER NOT NULL,
                updatedAtMillis INTEGER NOT NULL
            )
            """.trimIndent(),
        )
        legacyDatabase.execSQL(
            """
            CREATE TABLE checkIns (
                id TEXT PRIMARY KEY,
                habitId TEXT NOT NULL,
                dayKey TEXT NOT NULL,
                completedAtMillis INTEGER NOT NULL,
                recordedTimeZoneIdentifier TEXT NOT NULL
            )
            """.trimIndent(),
        )
        legacyDatabase.execSQL(
            """
            CREATE TABLE userPreferences (
                singletonKey INTEGER PRIMARY KEY,
                weekStartsOn INTEGER NOT NULL,
                defaultHomeTab TEXT NOT NULL,
                preferredStatisticsWindow TEXT NOT NULL
            )
            """.trimIndent(),
        )

        val trackerId = UUID.randomUUID().toString()
        val entryId = UUID.randomUUID().toString()
        legacyDatabase.execSQL(
            """
            INSERT INTO habits (
                id, name, colorToken, notes, scheduleType, scheduleWeekdays,
                scheduleTargetCount, isArchived, createdAtMillis, updatedAtMillis
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """.trimIndent(),
            arrayOf<Any?>(trackerId, "Read", "blue", "20 minutes", "daily", null, null, 0, 1776096000000L, 1776096000000L),
        )
        legacyDatabase.execSQL(
            """
            INSERT INTO checkIns (
                id, habitId, dayKey, completedAtMillis, recordedTimeZoneIdentifier
            ) VALUES (?, ?, ?, ?, ?)
            """.trimIndent(),
            arrayOf<Any?>(entryId, trackerId, "2026-04-13", 1776096000000L, "Asia/Shanghai"),
        )
        legacyDatabase.execSQL(
            """
            INSERT INTO userPreferences (
                singletonKey, weekStartsOn, defaultHomeTab, preferredStatisticsWindow
            ) VALUES (1, 1, 'STATISTICS', 'NINETY_DAYS')
            """.trimIndent(),
        )
        legacyDatabase.execSQL("PRAGMA user_version = 1")
        legacyDatabase.close()

        MarkerLocalStore.live(
            context = context,
            databaseName = databaseName,
            allowMainThreadQueries = true,
        ).use { migratedStore ->
            val trackers = migratedStore.fetchAllTrackers()
            val entries = migratedStore.fetchAllEntries()
            val preferences = migratedStore.fetchPreferences()

            assertEquals(1, trackers.size)
            assertEquals(TrackerKind.HABIT, trackers.single().kind)
            assertEquals(1, entries.size)
            assertEquals("Read", trackers.single().name)
            assertEquals(HomeTabPreference.STATISTICS, preferences?.defaultHomeTab)
            assertEquals(StatisticsWindow.NINETY_DAYS, preferences?.preferredStatisticsWindow)
        }
    }
}
