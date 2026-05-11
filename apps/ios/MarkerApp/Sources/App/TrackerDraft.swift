import Foundation
import MarkerDomain

enum TrackerScheduleKind: String, CaseIterable, Identifiable {
    case daily
    case weeklyOnDays
    case weeklyQuota

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily:
            "每天"
        case .weeklyOnDays:
            "按星期"
        case .weeklyQuota:
            "每周次数"
        }
    }
}

struct TrackerDraft: Identifiable {
    let id: UUID
    let existingTrackerID: UUID?
    let createdAt: Date

    var kind: TrackerKind
    var name: String
    var colorToken: String
    var notes: String
    var scheduleKind: TrackerScheduleKind
    var selectedWeekdays: Set<MarkerWeekday>
    var weeklyQuotaTarget: Int
    var isArchived: Bool

    static let availableColorTokens = ["blue", "green", "orange", "pink", "purple", "teal", "red"]

    static let empty = TrackerDraft(
        id: UUID(),
        existingTrackerID: nil,
        createdAt: Date(),
        kind: .habit,
        name: "",
        colorToken: "blue",
        notes: "",
        scheduleKind: .daily,
        selectedWeekdays: [.monday, .wednesday, .friday],
        weeklyQuotaTarget: 3,
        isArchived: false
    )

    static func template(for kind: TrackerKind) -> TrackerDraft {
        TrackerDraft(
            id: UUID(),
            existingTrackerID: nil,
            createdAt: Date(),
            kind: kind,
            name: "",
            colorToken: defaultColorToken(for: kind),
            notes: "",
            scheduleKind: .daily,
            selectedWeekdays: [.monday, .wednesday, .friday],
            weeklyQuotaTarget: 3,
            isArchived: false
        )
    }

    private static func defaultColorToken(for kind: TrackerKind) -> String {
        switch kind {
        case .habit:
            return "green"
        case .medication:
            return "blue"
        case .cycle:
            return "pink"
        case .custom:
            return "purple"
        }
    }

    init(
        id: UUID,
        existingTrackerID: UUID?,
        createdAt: Date,
        kind: TrackerKind,
        name: String,
        colorToken: String,
        notes: String,
        scheduleKind: TrackerScheduleKind,
        selectedWeekdays: Set<MarkerWeekday>,
        weeklyQuotaTarget: Int,
        isArchived: Bool
    ) {
        self.id = id
        self.existingTrackerID = existingTrackerID
        self.createdAt = createdAt
        self.kind = kind
        self.name = name
        self.colorToken = colorToken
        self.notes = notes
        self.scheduleKind = scheduleKind
        self.selectedWeekdays = selectedWeekdays
        self.weeklyQuotaTarget = weeklyQuotaTarget
        self.isArchived = isArchived
    }

    init(tracker: Tracker) {
        id = tracker.id
        existingTrackerID = tracker.id
        createdAt = tracker.createdAt
        kind = tracker.kind
        name = tracker.name
        colorToken = tracker.colorToken
        notes = tracker.notes
        isArchived = tracker.isArchived

        switch tracker.schedule {
        case .daily:
            scheduleKind = .daily
            selectedWeekdays = [.monday, .wednesday, .friday]
            weeklyQuotaTarget = 3
        case let .weeklyOnDays(days):
            scheduleKind = .weeklyOnDays
            selectedWeekdays = days
            weeklyQuotaTarget = 3
        case let .weeklyQuota(targetCount):
            scheduleKind = .weeklyQuota
            selectedWeekdays = [.monday, .wednesday, .friday]
            weeklyQuotaTarget = targetCount
        }
    }

    var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "请输入追踪项名称"
        }

        switch scheduleKind {
        case .daily:
            return nil
        case .weeklyOnDays where selectedWeekdays.isEmpty:
            return "请选择至少一个星期"
        case .weeklyQuota where weeklyQuotaTarget <= 0:
            return "每周目标次数必须大于 0"
        default:
            return nil
        }
    }

    func makeTracker(updatedAt: Date = Date()) -> Tracker {
        Tracker(
            id: existingTrackerID ?? id,
            kind: kind,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            colorToken: colorToken,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            schedule: schedule,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private var schedule: TrackerSchedule {
        switch scheduleKind {
        case .daily:
            return .daily
        case .weeklyOnDays:
            return .weeklyOnDays(selectedWeekdays)
        case .weeklyQuota:
            return .weeklyQuota(targetCount: max(weeklyQuotaTarget, 1))
        }
    }
}
