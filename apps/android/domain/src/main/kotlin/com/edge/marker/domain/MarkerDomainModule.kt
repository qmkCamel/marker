package com.edge.marker.domain

enum class MarkerDomainBoundary(val rawValue: String) {
    TRACKER_REPOSITORY(rawValue = "TrackerRepository"),
    TRACKING_ENTRY_REPOSITORY(rawValue = "TrackingEntryRepository"),
    STATISTICS_REPOSITORY(rawValue = "StatisticsRepository"),
    TRACKER_REMINDER_SCHEDULER(rawValue = "TrackerReminderScheduler"),
}

interface TrackerRepository

interface TrackingEntryRepository

interface StatisticsRepository

interface TrackerReminderScheduler

@Deprecated(message = "Use TrackerRepository instead", replaceWith = ReplaceWith("TrackerRepository"))
typealias HabitRepository = TrackerRepository

@Deprecated(message = "Use TrackingEntryRepository instead", replaceWith = ReplaceWith("TrackingEntryRepository"))
typealias CheckInRepository = TrackingEntryRepository

@Deprecated(message = "Use TrackerReminderScheduler instead", replaceWith = ReplaceWith("TrackerReminderScheduler"))
typealias ReminderScheduler = TrackerReminderScheduler

object MarkerDomainModule {
    val defaultBoundaries: List<MarkerDomainBoundary> = MarkerDomainBoundary.entries.toList()
}
