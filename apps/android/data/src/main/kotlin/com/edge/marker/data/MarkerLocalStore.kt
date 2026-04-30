package com.edge.marker.data

import android.content.Context
import androidx.room.Room
import com.edge.marker.domain.DayKey
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackingEntry
import com.edge.marker.domain.UserPreference

class MarkerLocalStore private constructor(
    private val database: MarkerDatabase,
) : AutoCloseable {
    fun fetchAllTrackers(): List<Tracker> = database.trackerDao().fetchAll().map(TrackerEntity::toDomain)

    fun fetchActiveTrackers(): List<Tracker> = database.trackerDao().fetchActive().map(TrackerEntity::toDomain)

    fun fetchArchivedTrackers(): List<Tracker> = database.trackerDao().fetchArchived().map(TrackerEntity::toDomain)

    fun saveTracker(tracker: Tracker) {
        database.trackerDao().upsert(TrackerEntity.fromDomain(tracker = tracker))
    }

    fun fetchAllEntries(): List<TrackingEntry> = database.trackingEntryDao().fetchAll().map(TrackingEntryEntity::toDomain)

    fun fetchEntries(dayKey: DayKey): List<TrackingEntry> =
        database.trackingEntryDao().fetchByDayKey(dayKey = dayKey.rawValue).map(TrackingEntryEntity::toDomain)

    fun fetchEntries(start: DayKey, end: DayKey): List<TrackingEntry> = database.trackingEntryDao()
        .fetchRange(startDayKey = start.rawValue, endDayKey = end.rawValue)
        .map(TrackingEntryEntity::toDomain)

    fun fetchEntry(trackerId: java.util.UUID, dayKey: DayKey): TrackingEntry? = database.trackingEntryDao()
        .fetchOne(trackerId = trackerId.toString(), dayKey = dayKey.rawValue)
        ?.toDomain()

    fun saveEntry(entry: TrackingEntry) {
        database.runInTransaction {
            val existing: TrackingEntryEntity? = database.trackingEntryDao()
                .fetchOne(trackerId = entry.trackerId.toString(), dayKey = entry.dayKey.rawValue)

            if (existing == null) {
                database.trackingEntryDao().insert(TrackingEntryEntity.fromDomain(entry = entry))
            } else {
                database.trackingEntryDao().update(
                    TrackingEntryEntity.fromDomain(entry = entry).copy(id = existing.id),
                )
            }
        }
    }

    fun deleteEntry(trackerId: java.util.UUID, dayKey: DayKey) {
        database.trackingEntryDao().delete(trackerId = trackerId.toString(), dayKey = dayKey.rawValue)
    }

    fun fetchWeeklyEntryCount(
        trackerId: java.util.UUID,
        dayKey: DayKey,
        weekStartsOn: MarkerWeekday,
    ): Int {
        val bounds: WeekBounds = weekBounds(dayKey = dayKey, weekStartsOn = weekStartsOn)

        return database.trackingEntryDao().countInRange(
            trackerId = trackerId.toString(),
            startDayKey = bounds.start.rawValue,
            endDayKey = bounds.end.rawValue,
        )
    }

    fun fetchPreferences(): UserPreference? = database.userPreferenceDao().fetch()?.toDomain()

    fun savePreferences(preference: UserPreference) {
        database.userPreferenceDao().upsert(UserPreferenceEntity.fromDomain(preference = preference))
    }

    override fun close() {
        database.close()
    }

    companion object {
        fun live(
            context: Context,
            databaseName: String = "marker.db",
            allowMainThreadQueries: Boolean = false,
        ): MarkerLocalStore {
            val builder = Room.databaseBuilder(
                context.applicationContext,
                MarkerDatabase::class.java,
                databaseName,
            ).addMigrations(MarkerDatabase.MIGRATION_1_2)

            if (allowMainThreadQueries) {
                builder.allowMainThreadQueries()
            }

            return MarkerLocalStore(database = builder.build())
        }

        fun inMemory(context: Context): MarkerLocalStore = MarkerLocalStore(
            database = Room.inMemoryDatabaseBuilder(
                context.applicationContext,
                MarkerDatabase::class.java,
            ).addMigrations(MarkerDatabase.MIGRATION_1_2)
                .allowMainThreadQueries()
                .build(),
        )

        private fun weekBounds(dayKey: DayKey, weekStartsOn: MarkerWeekday): WeekBounds {
            val offset: Int = (dayKey.weekday.rawValue - weekStartsOn.rawValue + 7) % 7
            val start: DayKey = dayKey.addingDays(days = -offset)
            val end: DayKey = start.addingDays(days = 6)
            return WeekBounds(start = start, end = end)
        }
    }
}

private data class WeekBounds(
    val start: DayKey,
    val end: DayKey,
)
