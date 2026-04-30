package com.edge.marker.app

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.edge.marker.data.MarkerLocalStore
import com.edge.marker.domain.DayKey
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.Tracker
import com.edge.marker.domain.TrackingEntry
import com.edge.marker.domain.StatisticsWindow
import com.edge.marker.domain.UserPreference
import java.util.Date
import java.util.TimeZone
import java.util.UUID

class MarkerAppModel(
    private val store: MarkerLocalStore,
    private val nowProvider: () -> Date = { Date() },
    private val timeZoneProvider: () -> TimeZone = { TimeZone.getDefault() },
) {
    var trackers: List<Tracker> by mutableStateOf(emptyList())
        private set

    var entries: List<TrackingEntry> by mutableStateOf(emptyList())
        private set

    var preferences: UserPreference by mutableStateOf(UserPreference.defaultValue)
        private set

    var lastErrorMessage: String? by mutableStateOf(null)
        private set

    init {
        reload()
    }

    val todayKey: DayKey
        get() = DayKey(date = nowProvider(), timeZone = timeZoneProvider())

    val todayItems: List<TodayTrackerItem>
        get() = TrackingEngine.buildTodayItems(
            trackers = trackers,
            entries = entries,
            dayKey = todayKey,
            weekStartsOn = preferences.weekStartsOn,
        )

    val historySections: List<HistoryDaySection>
        get() = TrackingEngine.buildHistorySections(trackers = trackers, entries = entries)

    val statisticsSummary: StatisticsSummary
        get() = TrackingEngine.buildStatisticsSummary(
            trackers = trackers,
            entries = entries,
            today = todayKey,
            preferences = preferences,
        )

    val archivedTrackers: List<Tracker>
        get() = trackers.filter { tracker -> tracker.isArchived }

    fun clearError() {
        lastErrorMessage = null
    }

    fun reload() {
        try {
            trackers = store.fetchAllTrackers()
            entries = store.fetchAllEntries()
            val savedPreferences: UserPreference? = store.fetchPreferences()
            preferences = savedPreferences ?: UserPreference.defaultValue
            if (savedPreferences == null) {
                store.savePreferences(UserPreference.defaultValue)
            }
            lastErrorMessage = null
        } catch (error: Exception) {
            lastErrorMessage = error.localizedMessage ?: error.toString()
        }
    }

    fun saveTracker(draft: TrackerDraft) {
        val validationMessage: String? = draft.validationMessage
        if (validationMessage != null) {
            lastErrorMessage = validationMessage
            return
        }

        try {
            store.saveTracker(draft.makeTracker())
            reload()
        } catch (error: Exception) {
            lastErrorMessage = error.localizedMessage ?: error.toString()
        }
    }

    fun toggleEntry(tracker: Tracker) {
        try {
            if (store.fetchEntry(trackerId = tracker.id, dayKey = todayKey) != null) {
                store.deleteEntry(trackerId = tracker.id, dayKey = todayKey)
            } else {
                store.saveEntry(
                    TrackingEntry(
                        id = UUID.randomUUID(),
                        trackerId = tracker.id,
                        dayKey = todayKey,
                        recordedAt = nowProvider(),
                        recordedTimeZoneIdentifier = timeZoneProvider().id,
                    ),
                )
            }
            reload()
        } catch (error: Exception) {
            lastErrorMessage = error.localizedMessage ?: error.toString()
        }
    }

    fun restoreTracker(tracker: Tracker) {
        saveTracker(TrackerDraft(tracker).copy(isArchived = false))
    }

    fun updateWeekStartsOn(weekday: MarkerWeekday) {
        savePreferences(
            UserPreference(
                weekStartsOn = weekday,
                defaultHomeTab = preferences.defaultHomeTab,
                preferredStatisticsWindow = preferences.preferredStatisticsWindow,
            ),
        )
    }

    fun updateStatisticsWindow(window: StatisticsWindow) {
        savePreferences(
            UserPreference(
                weekStartsOn = preferences.weekStartsOn,
                defaultHomeTab = preferences.defaultHomeTab,
                preferredStatisticsWindow = window,
            ),
        )
    }

    private fun savePreferences(updatedPreferences: UserPreference) {
        try {
            store.savePreferences(updatedPreferences)
            reload()
        } catch (error: Exception) {
            lastErrorMessage = error.localizedMessage ?: error.toString()
        }
    }
}
