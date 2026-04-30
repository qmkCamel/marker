import MarkerDomain
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: MarkerAppModel

    var body: some View {
        Form {
            Section("偏好") {
                Picker("周起始日", selection: Binding(
                    get: { model.preferences.weekStartsOn },
                    set: { model.updateWeekStartsOn($0) }
                )) {
                    ForEach(MarkerWeekday.allCases, id: \.self) { weekday in
                        Text(weekday.shortTitle).tag(weekday)
                    }
                }

                Picker("统计窗口", selection: Binding(
                    get: { model.preferences.preferredStatisticsWindow },
                    set: { model.updateStatisticsWindow($0) }
                )) {
                    ForEach([StatisticsWindow.sevenDays, .thirtyDays, .ninetyDays], id: \.self) { window in
                        Text(window.title).tag(window)
                    }
                }
            }

            Section("管理") {
                NavigationLink("已归档追踪项") {
                    ArchivedTrackersView(model: model)
                }
            }

            Section("关于") {
                LabeledContent("应用名", value: "Marker")
                LabeledContent("模式", value: "本地优先")
                LabeledContent("同步", value: "暂未启用")
            }
        }
        .navigationTitle("Settings")
    }
}

private struct ArchivedTrackersView: View {
    @ObservedObject var model: MarkerAppModel

    var body: some View {
        List {
            if model.archivedTrackers.isEmpty {
                ContentUnavailableView(
                    "没有归档追踪项",
                    systemImage: "archivebox",
                    description: Text("归档后的追踪项会显示在这里。")
                )
            } else {
                ForEach(model.archivedTrackers, id: \.id) { tracker in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tracker.name)
                            Text(MarkerPresentation.scheduleDescription(tracker.schedule))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("恢复") {
                            model.restoreTracker(tracker)
                        }
                    }
                }
            }
        }
        .navigationTitle("已归档追踪项")
    }
}
