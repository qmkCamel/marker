import SwiftUI

enum AppDestination: String, CaseIterable, Identifiable {
    case today
    case history
    case statistics
    case settings

    var id: Self {
        self
    }

    var title: String {
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

    var systemImage: String {
        switch self {
        case .today:
            "checklist"
        case .history:
            "calendar"
        case .statistics:
            "chart.bar"
        case .settings:
            "gearshape"
        }
    }

    @ViewBuilder
    func makeRootView(model: MarkerAppModel) -> some View {
        switch self {
        case .today:
            TodayView(model: model)
        case .history:
            HistoryView(model: model)
        case .statistics:
            StatisticsView(model: model)
        case .settings:
            SettingsView(model: model)
        }
    }
}
