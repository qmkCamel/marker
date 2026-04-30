import MarkerDomain
import SwiftUI

struct TrackingEntryEditorView: View {
    @State var draft: TrackingEntryDraft

    let onSave: (TrackingEntryDraft) -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Form {
            Section("追踪项") {
                LabeledContent("名称", value: draft.tracker.name)
                LabeledContent("类型", value: draft.tracker.kind.title)
                LabeledContent("日期", value: draft.dayKey.rawValue)
            }

            switch draft.tracker.kind {
            case .habit:
                habitSection
            case .medication:
                medicationSection
            case .cycle:
                cycleSection
            case .custom:
                noteSection
            }

            if let validationMessage = draft.validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }

            if draft.existingEntryID != nil {
                Section {
                    Button("删除今日记录", role: .destructive) {
                        onDelete()
                    }
                }
            }
        }
        .navigationTitle("记录内容")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") { onCancel() }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") { onSave(draft) }
                    .disabled(draft.validationMessage != nil)
            }
        }
    }

    private var habitSection: some View {
        Section("完成记录") {
            TextField("备注（可选）", text: $draft.note, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var medicationSection: some View {
        Section("用药记录") {
            Picker("状态", selection: $draft.medicationStatus) {
                ForEach(MedicationStatus.allCases, id: \.self) { status in
                    Text(status.title).tag(status)
                }
            }
            .pickerStyle(.segmented)

            TextField("剂量（可选）", text: $draft.doseText)
                .keyboardType(.decimalPad)

            TextField("单位（可选）", text: $draft.unit)
            TextField("备注（可选）", text: $draft.note, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var cycleSection: some View {
        Section("经期记录") {
            Picker("流量", selection: $draft.cycleFlow) {
                ForEach(CycleFlow.allCases, id: \.self) { flow in
                    Text(flow.title).tag(flow)
                }
            }

            ForEach(CycleSymptom.allCases, id: \.self) { symptom in
                Button {
                    if draft.selectedSymptoms.contains(symptom) {
                        draft.selectedSymptoms.remove(symptom)
                    } else {
                        draft.selectedSymptoms.insert(symptom)
                    }
                } label: {
                    HStack {
                        Text(symptom.title)
                        Spacer()
                        Image(systemName: draft.selectedSymptoms.contains(symptom) ? "checkmark.circle.fill" : "circle")
                    }
                }
                .buttonStyle(.plain)
            }

            TextField("备注（可选）", text: $draft.note, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var noteSection: some View {
        Section("备注记录") {
            TextField("记录内容", text: $draft.note, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}
