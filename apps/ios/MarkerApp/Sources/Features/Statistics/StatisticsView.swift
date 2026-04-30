import SwiftUI

struct StatisticsView: View {
    @ObservedObject var model: MarkerAppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryGrid

                Text("追踪项明细")
                    .font(.headline)

                if model.statisticsSummary.trackerBreakdown.isEmpty {
                    ContentUnavailableView(
                        "还没有统计数据",
                        systemImage: "chart.bar",
                        description: Text("先创建追踪项并完成几次记录。")
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(model.statisticsSummary.trackerBreakdown) { item in
                            HStack {
                                Circle()
                                    .fill(MarkerPresentation.color(for: item.colorToken))
                                    .frame(width: 10, height: 10)

                                Text(item.trackerName)
                                Spacer()
                                Text("\(item.totalEntryCount) 次")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Statistics")
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            summaryCard(title: "活跃追踪项", value: "\(model.statisticsSummary.activeTrackerCount)")
            summaryCard(title: "累计记录", value: "\(model.statisticsSummary.totalEntryCount)")
            summaryCard(
                title: model.preferences.preferredStatisticsWindow.title + "完成率",
                value: model.statisticsSummary.currentWindowDueCount == 0
                    ? "--"
                    : String(format: "%.0f%%", model.statisticsSummary.currentWindowCompletionRate * 100)
            )
            summaryCard(title: "当前连胜", value: "\(model.statisticsSummary.currentStreakDays) 天")
        }
    }

    private func summaryCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
