import MarkerDesignSystem
import MarkerDomain
import SwiftUI

struct TodayView: View {
    @ObservedObject var model: MarkerAppModel
    @State private var presentedDraft: TrackerDraft?
    @State private var presentedEntryDraft: TrackingEntryDraft?

    var body: some View {
        todayList
        .navigationTitle("Today")
        .toolbar(content: toolbarContent)
        .sheet(isPresented: trackerEditorPresented) { trackerEditorSheet }
        .sheet(isPresented: entryEditorPresented) { entryEditorSheet }
    }

    @ViewBuilder
    private var todaySection: some View {
        Section("今天要做") {
            if model.todayItems.isEmpty {
                ContentUnavailableView(
                    "今天很轻松",
                    systemImage: "sparkles",
                    description: Text("当前没有待追踪项目，或者你还没有创建追踪项。")
                )

                Button("创建第一个追踪项") {
                    presentedDraft = .empty
                }
            } else {
                ForEach(model.todayItems, id: \.id) { item in
                    TodayTrackerRow(
                        item: item,
                        scheduleText: scheduleDescription(for: item),
                        onPrimaryAction: {
                            if item.tracker.kind == .habit {
                                model.toggleEntry(for: item.tracker)
                            } else {
                                presentedEntryDraft = model.entryDraft(for: item.tracker)
                            }
                        },
                        onEditTracker: {
                            presentedDraft = TrackerDraft(tracker: item.tracker)
                        }
                    )
                }
            }
        }
    }

    private var progressCard: some View {
        let completed = model.todayItems.filter(\.isCompleted).count
        let total = model.todayItems.count
        let progress = total == 0 ? 0 : Double(completed) / Double(total)

        return VStack(alignment: .leading, spacing: 12) {
            Text("今日进度")
                .font(.headline)

            ProgressView(value: progress)
                .tint(.accentColor)

            Text(total == 0 ? "先创建追踪项，开始第一天记录。" : "已完成 \(completed) / \(total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(CGFloat(MarkerSpacing.screenPadding))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(MarkerCornerRadius.card), style: .continuous))
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var todayList: some View {
        List {
            Section {
                progressCard
            }

            todaySection
        }
    }

    private func scheduleDescription(for item: TodayTrackerItem) -> String {
        let base = "频率：\(MarkerPresentation.scheduleDescription(item.tracker.schedule))"
        guard let weeklyProgressText = item.weeklyProgressText else {
            return base
        }

        return "\(base) · 本周 \(weeklyProgressText)"
    }

    private var trackerEditorPresented: Binding<Bool> {
        Binding(
            get: { presentedDraft != nil },
            set: { newValue in
                if !newValue {
                    presentedDraft = nil
                }
            }
        )
    }

    private var entryEditorPresented: Binding<Bool> {
        Binding(
            get: { presentedEntryDraft != nil },
            set: { newValue in
                if !newValue {
                    presentedEntryDraft = nil
                }
            }
        )
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presentedDraft = .empty
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    @ViewBuilder
    private var trackerEditorSheet: some View {
        if let draft = presentedDraft {
            NavigationStack {
                TrackerEditorView(
                    draft: draft,
                    onSave: { updatedDraft in
                        model.saveTracker(from: updatedDraft)
                        presentedDraft = nil
                    },
                    onCancel: {
                        presentedDraft = nil
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var entryEditorSheet: some View {
        if let draft = presentedEntryDraft {
            NavigationStack {
                TrackingEntryEditorView(
                    draft: draft,
                    onSave: { updatedDraft in
                        model.saveEntry(from: updatedDraft)
                        presentedEntryDraft = nil
                    },
                    onDelete: {
                        model.deleteTodayEntry(for: draft.tracker)
                        presentedEntryDraft = nil
                    },
                    onCancel: {
                        presentedEntryDraft = nil
                    }
                )
            }
        }
    }
}

private struct TodayTrackerRow: View {
    let item: TodayTrackerItem
    let scheduleText: String
    let onPrimaryAction: () -> Void
    let onEditTracker: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(MarkerPresentation.color(for: item.tracker.colorToken))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.tracker.name)
                    .font(.headline)

                Text(scheduleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let entrySummaryText = item.entrySummaryText {
                    Text("今日记录：\(entrySummaryText)")
                        .font(.footnote)
                        .foregroundStyle(item.isCompleted ? Color.secondary : Color.orange)
                }

                if !item.tracker.notes.isEmpty {
                    Text(item.tracker.notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: onPrimaryAction) {
                actionView
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onEditTracker)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var actionView: some View {
        if item.tracker.kind == .habit {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 28))
                .foregroundStyle(item.isCompleted ? MarkerPresentation.color(for: item.tracker.colorToken) : .secondary)
        } else {
            Text(item.hasRecord ? "编辑记录" : "记录")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(actionBackground)
                .clipShape(Capsule())
        }
    }

    private var actionBackground: Color {
        if item.hasRecord {
            return Color.secondary.opacity(0.15)
        }

        return MarkerPresentation.color(for: item.tracker.colorToken).opacity(0.15)
    }
}
