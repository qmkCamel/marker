import MarkerDomain
import SwiftUI

enum MarkerPresentation {
    static func color(for token: String) -> Color {
        switch token {
        case "blue":
            .blue
        case "green":
            .green
        case "orange":
            .orange
        case "pink":
            .pink
        case "purple":
            .purple
        case "teal":
            .teal
        case "red":
            .red
        default:
            .accentColor
        }
    }

    static func scheduleDescription(_ schedule: TrackerSchedule) -> String {
        switch schedule {
        case .daily:
            return "每天"
        case let .weeklyOnDays(days):
            return days
                .sorted { $0.rawValue < $1.rawValue }
                .map(\.shortTitle)
                .joined(separator: "、")
        case let .weeklyQuota(targetCount):
            return "每周 \(targetCount) 次"
        }
    }
}
