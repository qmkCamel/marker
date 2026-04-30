public enum MarkerDomainBoundary: String, CaseIterable, Sendable {
    case trackerRepository = "TrackerRepository"
    case trackingEntryRepository = "TrackingEntryRepository"
    case statisticsRepository = "StatisticsRepository"
    case trackerReminderScheduler = "TrackerReminderScheduler"
}

public protocol TrackerRepository: Sendable {}

public protocol TrackingEntryRepository: Sendable {}

public protocol StatisticsRepository: Sendable {}

public protocol TrackerReminderScheduler: Sendable {}

@available(*, deprecated, renamed: "TrackingEntryRepository")
public typealias CheckInRepository = TrackingEntryRepository

@available(*, deprecated, renamed: "TrackerReminderScheduler")
public typealias ReminderScheduler = TrackerReminderScheduler

public enum MarkerDomainModule {
    public static let defaultBoundaries: [MarkerDomainBoundary] = MarkerDomainBoundary.allCases
}
