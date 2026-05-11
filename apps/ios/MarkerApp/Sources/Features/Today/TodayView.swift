import MarkerDesignSystem
import MarkerDomain
import SwiftUI

struct TodayView: View {
    @ObservedObject var model: MarkerAppModel
    @State private var presentedDraft: TrackerDraft?
    @State private var presentedEntryDraft: TrackingEntryDraft?
    @State private var templatePickerPresented = false

    var body: some View {
        todayList
            .navigationTitle("Today")
            .toolbar(content: toolbarContent)
            .sheet(isPresented: $templatePickerPresented) { templatePickerSheet }
            .sheet(isPresented: trackerEditorPresented) { trackerEditorSheet }
            .sheet(isPresented: entryEditorPresented) { entryEditorSheet }
    }

    private var todayList: some View {
        List {
            Section {
                summaryCard
            }

            todayContent

            Section {
                localFirstRow
            }
        }
    }

    @ViewBuilder
    private var todayContent: some View {
        let overview = model.todayOverview

        if overview.activeTrackerCount == 0 {
            Section {
                ContentUnavailableView(
                    "先记录一件照顾自己的事",
                    systemImage: "plus.circle",
                    description: Text("可以从习惯、用药、经期或自定义记录开始。")
                )

                Button("创建追踪项") {
                    templatePickerPresented = true
                }
                .accessibilityIdentifier("today.addTracker")
            }
        } else if overview.pendingItems.isEmpty && overview.recordedItems.isEmpty {
            Section {
                ContentUnavailableView(
                    "今天很轻松",
                    systemImage: "sparkles",
                    description: Text("今天没有按计划需要确认的项目。")
                )
            }
        } else {
            if !overview.pendingItems.isEmpty {
                Section("待确认 · \(overview.pendingItems.count)") {
                    ForEach(overview.pendingItems, id: \.id) { item in
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

            if !overview.recordedItems.isEmpty {
                Section("今日已记录 · \(overview.recordedItems.count)") {
                    ForEach(overview.recordedItems, id: \.id) { item in
                        TodayTrackerRow(
                            item: item,
                            scheduleText: scheduleDescription(for: item),
                            onPrimaryAction: {
                                presentedEntryDraft = model.entryDraft(for: item.tracker)
                            },
                            onEditTracker: {
                                presentedEntryDraft = model.entryDraft(for: item.tracker)
                            }
                        )
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        let overview = model.todayOverview

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(overview.summaryText)
                        .font(.headline)

                    Text("记录会按当前设备时区归属到今天。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label("本地保存", systemImage: "checkmark.shield")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12))
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(tileColor(index: index, overview: overview))
                        .frame(width: 18, height: 18)
                }
            }
            .accessibilityHidden(true)
        }
        .padding(CGFloat(MarkerSpacing.screenPadding))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(MarkerCornerRadius.card), style: .continuous))
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var localFirstRow: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text("记录保存在本机")
                    .font(.subheadline.weight(.semibold))
                Text("同步和自动备份暂未启用。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "lock.shield")
                .foregroundStyle(Color.green)
        }
    }

    private func tileColor(index: Int, overview: TodayOverview) -> Color {
        let recordedCount = overview.recordedItems.count
        let pendingCount = overview.pendingItems.count

        if index < recordedCount {
            return Color.green.opacity(0.75)
        }

        if index < recordedCount + pendingCount {
            return Color.orange.opacity(0.35)
        }

        return Color.secondary.opacity(0.12)
    }

    private func scheduleDescription(for item: TodayTrackerItem) -> String {
        let base = MarkerPresentation.scheduleDescription(item.tracker.schedule)
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
                templatePickerPresented = true
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add")
            .accessibilityIdentifier("today.addTracker")
        }
    }

    private var templatePickerSheet: some View {
        NavigationStack {
            TrackerTemplatePickerView(
                onSelect: { kind in
                    templatePickerPresented = false
                    DispatchQueue.main.async {
                        presentedDraft = .template(for: kind)
                    }
                },
                onCancel: {
                    templatePickerPresented = false
                }
            )
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

private struct TrackerTemplatePickerView: View {
    let onSelect: (TrackerKind) -> Void
    let onCancel: () -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("先选择想记录的类型")
                        .font(.title3.bold())
                    Text("选择模板后，再填写名称、颜色和频率。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)

            Section("模板") {
                ForEach(TrackerKind.allCases, id: \.self) { kind in
                    Button {
                        onSelect(kind)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: iconName(for: kind))
                                .font(.title3)
                                .foregroundStyle(MarkerPresentation.color(for: colorToken(for: kind)))
                                .frame(width: 36, height: 36)
                                .background(MarkerPresentation.color(for: colorToken(for: kind)).opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(kind.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(description(for: kind))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("trackerTemplate.\(kind.rawValue)")
                }
            }
        }
        .navigationTitle("创建追踪项")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消", action: onCancel)
                    .accessibilityIdentifier("trackerTemplate.cancel")
            }
        }
    }

    private func iconName(for kind: TrackerKind) -> String {
        switch kind {
        case .habit:
            return "checkmark.circle"
        case .medication:
            return "pills"
        case .cycle:
            return "drop"
        case .custom:
            return "note.text"
        }
    }

    private func colorToken(for kind: TrackerKind) -> String {
        TrackerDraft.template(for: kind).colorToken
    }

    private func description(for kind: TrackerKind) -> String {
        switch kind {
        case .habit:
            return "适合喝水、运动、早睡"
        case .medication:
            return "确认已服用或已跳过"
        case .cycle:
            return "记录流量、症状和备注"
        case .custom:
            return "写下其他状态或观察"
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
                    Text(statusSummary(entrySummaryText))
                        .font(.footnote)
                        .foregroundStyle(item.isSkippedMedication ? Color.orange : Color.secondary)
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
        if item.hasRecord {
            recordedStatusView
        } else if item.tracker.kind == .habit {
            Image(systemName: "circle")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
                .accessibilityLabel("记录完成")
        } else {
            Text(pendingActionTitle)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(MarkerPresentation.color(for: item.tracker.colorToken).opacity(0.15))
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private var recordedStatusView: some View {
        if item.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(MarkerPresentation.color(for: item.tracker.colorToken))
                .accessibilityLabel("已记录")
        } else {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.orange)
                .accessibilityLabel("已记录但不计入完成")
        }
    }

    private var pendingActionTitle: String {
        switch item.tracker.kind {
        case .habit:
            return "完成"
        case .medication:
            return "确认"
        case .cycle:
            return "记录状态"
        case .custom:
            return "写记录"
        }
    }

    private func statusSummary(_ summary: String) -> String {
        if item.isSkippedMedication {
            return "\(summary) · 不计入服用"
        }

        return summary
    }
}
