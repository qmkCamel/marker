import MarkerDomain
import SwiftUI

struct TrackerEditorView: View {
    @State var draft: TrackerDraft

    let onSave: (TrackerDraft) -> Void
    let onCancel: () -> Void

    var body: some View {
        Form {
            Section("基础信息") {
                Picker("类型", selection: $draft.kind) {
                    ForEach(TrackerKind.allCases, id: \.self) { kind in
                        Text(kind.title).tag(kind)
                    }
                }

                TextField("追踪项名称", text: $draft.name)
                TextField("备注", text: $draft.notes, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("颜色") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(TrackerDraft.availableColorTokens, id: \.self) { token in
                        Button {
                            draft.colorToken = token
                        } label: {
                            Circle()
                                .fill(MarkerPresentation.color(for: token))
                                .frame(width: 28, height: 28)
                                .overlay {
                                    if draft.colorToken == token {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("频率") {
                Picker("类型", selection: $draft.scheduleKind) {
                    ForEach(TrackerScheduleKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }

                switch draft.scheduleKind {
                case .daily:
                    Text("每天都算应完成")
                        .foregroundStyle(.secondary)
                case .weeklyOnDays:
                    weekdayPicker
                case .weeklyQuota:
                    Stepper("每周 \(draft.weeklyQuotaTarget) 次", value: $draft.weeklyQuotaTarget, in: 1...14)
                }
            }

            if draft.existingTrackerID != nil {
                Section("状态") {
                    Toggle("归档该追踪项", isOn: $draft.isArchived)
                }
            }

            if let validationMessage = draft.validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(draft.existingTrackerID == nil ? "新建追踪项" : "编辑追踪项")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") {
                    onCancel()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    onSave(draft)
                }
                .disabled(draft.validationMessage != nil)
            }
        }
    }

    private var weekdayPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择星期")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(MarkerWeekday.allCases, id: \.self) { weekday in
                Button {
                    if draft.selectedWeekdays.contains(weekday) {
                        draft.selectedWeekdays.remove(weekday)
                    } else {
                        draft.selectedWeekdays.insert(weekday)
                    }
                } label: {
                    HStack {
                        Text(weekday.shortTitle)
                        Spacer()
                        Image(systemName: draft.selectedWeekdays.contains(weekday) ? "checkmark.circle.fill" : "circle")
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
