import SwiftUI

struct HistoryView: View {
    @ObservedObject var model: MarkerAppModel

    var body: some View {
        List {
            if model.historySections.isEmpty {
                ContentUnavailableView(
                    "还没有历史记录",
                    systemImage: "calendar",
                    description: Text("完成一次记录后，这里会显示每天的明细。")
                )
            } else {
                ForEach(model.historySections) { section in
                    NavigationLink {
                        HistoryDayDetailView(section: section)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(section.dayKey.rawValue)
                                    .font(.headline)
                                Text("完成 \(section.items.count) 项")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

private struct HistoryDayDetailView: View {
    let section: HistoryDaySection

    var body: some View {
        List(section.items) { item in
            HStack(spacing: 12) {
                Circle()
                    .fill(MarkerPresentation.color(for: item.colorToken))
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.trackerName)
                    Text(item.payloadSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(item.recordedAt.formatted(date: .omitted, time: .shortened))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(section.dayKey.rawValue)
    }
}
