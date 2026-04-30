import Foundation

public enum TrackerKind: String, CaseIterable, Hashable, Sendable, Codable {
    case habit
    case medication
    case cycle
    case custom

    public var title: String {
        switch self {
        case .habit:
            "习惯"
        case .medication:
            "用药"
        case .cycle:
            "经期"
        case .custom:
            "自定义"
        }
    }
}

public enum MarkerWeekday: Int, CaseIterable, Hashable, Sendable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    public init?(foundationWeekday: Int) {
        self.init(rawValue: foundationWeekday)
    }

    public var shortTitle: String {
        switch self {
        case .sunday:
            "周日"
        case .monday:
            "周一"
        case .tuesday:
            "周二"
        case .wednesday:
            "周三"
        case .thursday:
            "周四"
        case .friday:
            "周五"
        case .saturday:
            "周六"
        }
    }
}

public enum TrackerSchedule: Equatable, Hashable, Sendable {
    case daily
    case weeklyOnDays(Set<MarkerWeekday>)
    case weeklyQuota(targetCount: Int)

    public func isDue(on day: DayKey, completedCountInWeek: Int = 0) -> Bool {
        switch self {
        case .daily:
            return true
        case let .weeklyOnDays(days):
            guard let weekday = day.weekday else {
                return false
            }

            return days.contains(weekday)
        case let .weeklyQuota(targetCount):
            return completedCountInWeek < max(targetCount, 1)
        }
    }
}

public struct LocalTime: Equatable, Hashable, Sendable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

public enum HomeTabPreference: String, Equatable, Hashable, Sendable, Codable {
    case today
    case history
    case statistics
    case settings

    public var title: String {
        switch self {
        case .today:
            "Today"
        case .history:
            "History"
        case .statistics:
            "Statistics"
        case .settings:
            "Settings"
        }
    }
}

public enum StatisticsWindow: String, Equatable, Hashable, Sendable, Codable {
    case sevenDays
    case thirtyDays
    case ninetyDays

    public var dayCount: Int {
        switch self {
        case .sevenDays:
            7
        case .thirtyDays:
            30
        case .ninetyDays:
            90
        }
    }

    public var title: String {
        switch self {
        case .sevenDays:
            "近 7 天"
        case .thirtyDays:
            "近 30 天"
        case .ninetyDays:
            "近 90 天"
        }
    }
}

public struct Tracker: Equatable, Sendable {
    public let id: UUID
    public let kind: TrackerKind
    public let name: String
    public let colorToken: String
    public let notes: String
    public let schedule: TrackerSchedule
    public let isArchived: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        kind: TrackerKind = .habit,
        name: String,
        colorToken: String,
        notes: String,
        schedule: TrackerSchedule,
        isArchived: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.colorToken = colorToken
        self.notes = notes
        self.schedule = schedule
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct TrackingEntry: Equatable, Sendable {
    public let id: UUID
    public let trackerId: UUID
    public let dayKey: DayKey
    public let recordedAt: Date
    public let recordedTimeZoneIdentifier: String
    public let payload: TrackingPayload

    public init(
        id: UUID,
        trackerId: UUID,
        dayKey: DayKey,
        recordedAt: Date,
        recordedTimeZoneIdentifier: String,
        payload: TrackingPayload = .completion()
    ) {
        self.id = id
        self.trackerId = trackerId
        self.dayKey = dayKey
        self.recordedAt = recordedAt
        self.recordedTimeZoneIdentifier = recordedTimeZoneIdentifier
        self.payload = payload
    }

    public var summary: String { payload.summary }
    public var countsAsCompletion: Bool { payload.countsAsCompletion }
}

public struct TrackerReminder: Equatable, Sendable {
    public let id: UUID
    public let trackerId: UUID
    public let localTime: LocalTime
    public let weekdays: Set<MarkerWeekday>
    public let isEnabled: Bool

    public init(
        id: UUID,
        trackerId: UUID,
        localTime: LocalTime,
        weekdays: Set<MarkerWeekday>,
        isEnabled: Bool
    ) {
        self.id = id
        self.trackerId = trackerId
        self.localTime = localTime
        self.weekdays = weekdays
        self.isEnabled = isEnabled
    }
}

public struct UserPreference: Equatable, Sendable {
    public let weekStartsOn: MarkerWeekday
    public let defaultHomeTab: HomeTabPreference
    public let preferredStatisticsWindow: StatisticsWindow

    public init(
        weekStartsOn: MarkerWeekday,
        defaultHomeTab: HomeTabPreference,
        preferredStatisticsWindow: StatisticsWindow
    ) {
        self.weekStartsOn = weekStartsOn
        self.defaultHomeTab = defaultHomeTab
        self.preferredStatisticsWindow = preferredStatisticsWindow
    }

    public static let defaultValue = UserPreference(
        weekStartsOn: .monday,
        defaultHomeTab: .today,
        preferredStatisticsWindow: .thirtyDays
    )
}
