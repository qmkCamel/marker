package com.edge.marker.data

import androidx.room.Dao
import androidx.room.Database
import androidx.room.Insert
import androidx.room.migration.Migration
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.RoomDatabase
import androidx.room.Update
import androidx.sqlite.db.SupportSQLiteDatabase

@Dao
interface TrackerDao {
    @Query("SELECT * FROM trackers ORDER BY isArchived ASC, createdAtMillis ASC")
    fun fetchAll(): List<TrackerEntity>

    @Query("SELECT * FROM trackers WHERE isArchived = 0 ORDER BY createdAtMillis ASC")
    fun fetchActive(): List<TrackerEntity>

    @Query("SELECT * FROM trackers WHERE isArchived = 1 ORDER BY updatedAtMillis DESC")
    fun fetchArchived(): List<TrackerEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun upsert(tracker: TrackerEntity)
}

@Dao
interface TrackingEntryDao {
    @Query("SELECT * FROM trackingEntries ORDER BY dayKey DESC, recordedAtMillis DESC")
    fun fetchAll(): List<TrackingEntryEntity>

    @Query("SELECT * FROM trackingEntries WHERE dayKey = :dayKey ORDER BY recordedAtMillis DESC")
    fun fetchByDayKey(dayKey: String): List<TrackingEntryEntity>

    @Query(
        """
        SELECT * FROM trackingEntries
        WHERE dayKey >= :startDayKey AND dayKey <= :endDayKey
        ORDER BY dayKey DESC, recordedAtMillis DESC
        """,
    )
    fun fetchRange(startDayKey: String, endDayKey: String): List<TrackingEntryEntity>

    @Query("SELECT * FROM trackingEntries WHERE trackerId = :trackerId AND dayKey = :dayKey LIMIT 1")
    fun fetchOne(trackerId: String, dayKey: String): TrackingEntryEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(entry: TrackingEntryEntity)

    @Update
    fun update(entry: TrackingEntryEntity)

    @Query("DELETE FROM trackingEntries WHERE trackerId = :trackerId AND dayKey = :dayKey")
    fun delete(trackerId: String, dayKey: String)

    @Query(
        """
        SELECT COUNT(*) FROM trackingEntries
        WHERE trackerId = :trackerId AND dayKey >= :startDayKey AND dayKey <= :endDayKey
        """,
    )
    fun countInRange(trackerId: String, startDayKey: String, endDayKey: String): Int
}

@Dao
interface UserPreferenceDao {
    @Query("SELECT * FROM userPreferences LIMIT 1")
    fun fetch(): UserPreferenceEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun upsert(preference: UserPreferenceEntity)
}

@Database(
    entities = [TrackerEntity::class, TrackingEntryEntity::class, UserPreferenceEntity::class],
    version = 2,
    exportSchema = true,
)
abstract class MarkerDatabase : RoomDatabase() {
    abstract fun trackerDao(): TrackerDao

    abstract fun trackingEntryDao(): TrackingEntryDao

    abstract fun userPreferenceDao(): UserPreferenceDao

    companion object {
        val MIGRATION_1_2: Migration = object : Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                val legacyUserPreferenceTableExists: Boolean = db.tableExists(tableName = "userPreferences")
                if (legacyUserPreferenceTableExists) {
                    db.execSQL("ALTER TABLE userPreferences RENAME TO userPreferences_legacy")
                }

                db.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS trackers (
                        id TEXT NOT NULL PRIMARY KEY,
                        kind TEXT NOT NULL,
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
                db.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS trackingEntries (
                        id TEXT NOT NULL PRIMARY KEY,
                        trackerId TEXT NOT NULL,
                        dayKey TEXT NOT NULL,
                        recordedAtMillis INTEGER NOT NULL,
                        recordedTimeZoneIdentifier TEXT NOT NULL,
                        FOREIGN KEY(trackerId) REFERENCES trackers(id) ON DELETE CASCADE
                    )
                    """.trimIndent(),
                )
                db.execSQL(
                    """
                    CREATE UNIQUE INDEX IF NOT EXISTS index_trackingEntries_trackerId_dayKey
                    ON trackingEntries(trackerId, dayKey)
                    """.trimIndent(),
                )
                db.execSQL(
                    """
                    CREATE INDEX IF NOT EXISTS index_trackingEntries_dayKey
                    ON trackingEntries(dayKey)
                    """.trimIndent(),
                )
                db.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS userPreferences (
                        singletonKey INTEGER NOT NULL PRIMARY KEY,
                        weekStartsOn INTEGER NOT NULL,
                        defaultHomeTab TEXT NOT NULL,
                        preferredStatisticsWindow TEXT NOT NULL
                    )
                    """.trimIndent(),
                )

                val legacyHabitTableExists: Boolean = db.tableExists(tableName = "habits")
                val legacyCheckInTableExists: Boolean = db.tableExists(tableName = "checkIns")
                val trackerCount: Int = db.count(sql = "SELECT COUNT(*) FROM trackers")
                val entryCount: Int = db.count(sql = "SELECT COUNT(*) FROM trackingEntries")

                if (legacyHabitTableExists && trackerCount == 0) {
                    db.execSQL(
                        """
                        INSERT INTO trackers (
                            id, kind, name, colorToken, notes, scheduleType, scheduleWeekdays,
                            scheduleTargetCount, isArchived, createdAtMillis, updatedAtMillis
                        )
                        SELECT
                            id,
                            'habit',
                            name,
                            colorToken,
                            notes,
                            scheduleType,
                            scheduleWeekdays,
                            scheduleTargetCount,
                            isArchived,
                            createdAtMillis,
                            updatedAtMillis
                        FROM habits
                        """.trimIndent(),
                    )
                }

                if (legacyCheckInTableExists && entryCount == 0) {
                    db.execSQL(
                        """
                        INSERT INTO trackingEntries (
                            id, trackerId, dayKey, recordedAtMillis, recordedTimeZoneIdentifier
                        )
                        SELECT
                            id,
                            habitId,
                            dayKey,
                            completedAtMillis,
                            recordedTimeZoneIdentifier
                        FROM checkIns
                        """.trimIndent(),
                    )
                }

                if (legacyUserPreferenceTableExists) {
                    db.execSQL(
                        """
                        INSERT INTO userPreferences (
                            singletonKey, weekStartsOn, defaultHomeTab, preferredStatisticsWindow
                        )
                        SELECT
                            singletonKey,
                            weekStartsOn,
                            defaultHomeTab,
                            preferredStatisticsWindow
                        FROM userPreferences_legacy
                        """.trimIndent(),
                    )
                    db.execSQL("DROP TABLE userPreferences_legacy")
                }
            }
        }
    }
}

private fun SupportSQLiteDatabase.tableExists(tableName: String): Boolean =
    query("SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '$tableName'").use { cursor ->
        cursor.moveToFirst()
        cursor.getInt(0) > 0
    }

private fun SupportSQLiteDatabase.count(sql: String): Int =
    query(sql).use { cursor ->
        cursor.moveToFirst()
        cursor.getInt(0)
    }
