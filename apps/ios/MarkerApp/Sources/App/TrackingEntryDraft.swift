import Foundation
import MarkerDomain

struct TrackingEntryDraft: Identifiable {
    let id: UUID
    let tracker: Tracker
    let dayKey: DayKey
    let existingEntryID: UUID?
    let recordedAt: Date

    var medicationStatus: MedicationStatus
    var doseText: String
    var unit: String
    var cycleFlow: CycleFlow
    var selectedSymptoms: Set<CycleSymptom>
    var note: String

    init(tracker: Tracker, dayKey: DayKey, existingEntry: TrackingEntry? = nil) {
        self.id = existingEntry?.id ?? UUID()
        self.tracker = tracker
        self.dayKey = dayKey
        self.existingEntryID = existingEntry?.id
        self.recordedAt = existingEntry?.recordedAt ?? Date()

        switch existingEntry?.payload.kind ?? TrackingPayload.defaultPayload(for: tracker.kind).kind {
        case .completion:
            self.medicationStatus = .taken
            self.doseText = ""
            self.unit = ""
            self.cycleFlow = .medium
            self.selectedSymptoms = []
            self.note = existingEntry?.payload.note ?? ""
        case .medication:
            let payload = existingEntry?.payload ?? .defaultPayload(for: tracker.kind)
            self.medicationStatus = payload.medicationStatus ?? .taken
            if let dose = payload.dose {
                self.doseText = dose.rounded(.towardZero) == dose ? String(Int(dose)) : String(dose)
            } else {
                self.doseText = ""
            }
            self.unit = payload.unit ?? ""
            self.cycleFlow = .medium
            self.selectedSymptoms = []
            self.note = payload.note
        case .cycle:
            let payload = existingEntry?.payload ?? .defaultPayload(for: tracker.kind)
            self.medicationStatus = .taken
            self.doseText = ""
            self.unit = ""
            self.cycleFlow = payload.cycleFlow ?? .medium
            self.selectedSymptoms = Set(payload.symptoms)
            self.note = payload.note
        case .note:
            self.medicationStatus = .taken
            self.doseText = ""
            self.unit = ""
            self.cycleFlow = .medium
            self.selectedSymptoms = []
            self.note = existingEntry?.payload.note ?? ""
        }
    }

    var validationMessage: String? {
        switch tracker.kind {
        case .custom where note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty:
            return "请输入记录内容"
        case .medication where !doseText.isEmpty && Double(doseText) == nil:
            return "剂量格式不正确"
        default:
            return nil
        }
    }

    func makeEntry(timeZoneIdentifier: String = TimeZone.current.identifier) -> TrackingEntry {
        TrackingEntry(
            id: existingEntryID ?? id,
            trackerId: tracker.id,
            dayKey: dayKey,
            recordedAt: recordedAt,
            recordedTimeZoneIdentifier: timeZoneIdentifier,
            payload: payload
        )
    }

    private var payload: TrackingPayload {
        switch tracker.kind {
        case .habit:
            return .completion(note: note)
        case .medication:
            return .medication(
                status: medicationStatus,
                dose: doseText.isEmpty ? nil : Double(doseText),
                unit: unit.isEmpty ? nil : unit,
                note: note
            )
        case .cycle:
            return .cycle(
                flow: cycleFlow,
                symptoms: selectedSymptoms.sorted { $0.rawValue < $1.rawValue },
                note: note
            )
        case .custom:
            return .note(note)
        }
    }
}
