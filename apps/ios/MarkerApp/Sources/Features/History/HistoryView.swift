import MarkerDomain
import SwiftUI

struct HistoryView: View {
    @ObservedObject var model: MarkerAppModel
    @State private var backfillPickerPresented = false
    @State private var presentedBackfillDraft: TrackingEntryDraft?

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    backfillPickerPresented = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Backfill")
                .accessibilityIdentifier("history.backfill")
            }
        }
        .sheet(isPresented: $backfillPickerPresented) {
            NavigationStack {
                BackfillEntryPickerView(
                    trackers: model.activeTrackers,
                    onContinue: { tracker, dayKey in
                        let draft = model.entryDraft(for: tracker, dayKey: dayKey)
                        backfillPickerPresented = false
                        DispatchQueue.main.async {
                            presentedBackfillDraft = draft
                        }
                    },
                    onCancel: {
                        backfillPickerPresented = false
                    }
                )
            }
        }
        .sheet(isPresented: backfillEditorPresented) {
            if let draft = presentedBackfillDraft {
                NavigationStack {
                    TrackingEntryEditorView(
                        draft: draft,
                        onSave: { updatedDraft in
                            model.saveEntry(from: updatedDraft)
                            presentedBackfillDraft = nil
                        },
                        onDelete: {
                            model.deleteEntry(for: draft.tracker, dayKey: draft.dayKey)
                            presentedBackfillDraft = nil
                        },
                        onCancel: {
                            presentedBackfillDraft = nil
                        }
                    )
                }
            }
        }
    }

    private var backfillEditorPresented: Binding<Bool> {
        Binding(
            get: { presentedBackfillDraft != nil },
            set: { newValue in
                if !newValue {
                    presentedBackfillDraft = nil
                }
            }
        )
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

private struct BackfillEntryPickerView: View {
    let trackers: [Tracker]
    let onContinue: (Tracker, DayKey) -> Void
    let onCancel: () -> Void

    @State private var selectedDate: Date
    @State private var selectedTrackerID: UUID?

    init(
        trackers: [Tracker],
        today: Date = Date(),
        onContinue: @escaping (Tracker, DayKey) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.trackers = trackers
        self.onContinue = onContinue
        self.onCancel = onCancel

        let defaultDate = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        _selectedDate = State(initialValue: defaultDate)
        _selectedTrackerID = State(initialValue: trackers.first?.id)
    }

    var body: some View {
        Form {
            if trackers.isEmpty {
                ContentUnavailableView(
                    "还没有可补记的追踪项",
                    systemImage: "tray",
                    description: Text("先创建一个追踪项，再回来补记。")
                )
            } else {
                Section("补记日期") {
                    DatePicker(
                        "日期",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .accessibilityIdentifier("history.backfill.date")
                }

                Section("追踪项") {
                    Picker("追踪项", selection: $selectedTrackerID) {
                        ForEach(trackers, id: \.id) { tracker in
                            Text(tracker.name).tag(Optional(tracker.id))
                        }
                    }
                    .accessibilityIdentifier("history.backfill.tracker")
                }
            }
        }
        .navigationTitle("补记")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消", action: onCancel)
                    .accessibilityIdentifier("history.backfill.cancel")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("继续") {
                    guard let tracker = selectedTracker else { return }

                    onContinue(
                        tracker,
                        DayKey(date: selectedDate, timeZone: .current)
                    )
                }
                .disabled(selectedTracker == nil)
                .accessibilityIdentifier("history.backfill.continue")
            }
        }
    }

    private var selectedTracker: Tracker? {
        trackers.first { $0.id == selectedTrackerID }
    }
}
