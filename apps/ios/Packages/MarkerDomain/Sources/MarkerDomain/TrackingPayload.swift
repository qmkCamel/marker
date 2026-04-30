import Foundation

public enum TrackingPayloadKind: String, CaseIterable, Hashable, Sendable, Codable {
    case completion
    case medication
    case cycle
    case note
}

public enum MedicationStatus: String, CaseIterable, Hashable, Sendable, Codable {
    case taken
    case skipped

    public var title: String {
        switch self {
        case .taken:
            "已服用"
        case .skipped:
            "已跳过"
        }
    }
}

public enum CycleFlow: String, CaseIterable, Hashable, Sendable, Codable {
    case spotting
    case light
    case medium
    case heavy

    public var title: String {
        switch self {
        case .spotting:
            "点滴"
        case .light:
            "少量"
        case .medium:
            "中量"
        case .heavy:
            "大量"
        }
    }
}

public enum CycleSymptom: String, CaseIterable, Hashable, Sendable, Codable {
    case cramp
    case bloating
    case headache
    case fatigue
    case backPain

    public var title: String {
        switch self {
        case .cramp:
            "腹痛"
        case .bloating:
            "腹胀"
        case .headache:
            "头痛"
        case .fatigue:
            "疲劳"
        case .backPain:
            "腰酸"
        }
    }
}

public struct TrackingPayload: Equatable, Hashable, Sendable, Codable {
    public let kind: TrackingPayloadKind
    public let medicationStatus: MedicationStatus?
    public let dose: Double?
    public let unit: String?
    public let cycleFlow: CycleFlow?
    public let symptoms: [CycleSymptom]
    public let note: String

    public init(
        kind: TrackingPayloadKind,
        medicationStatus: MedicationStatus? = nil,
        dose: Double? = nil,
        unit: String? = nil,
        cycleFlow: CycleFlow? = nil,
        symptoms: [CycleSymptom] = [],
        note: String = ""
    ) {
        self.kind = kind
        self.medicationStatus = medicationStatus
        self.dose = dose
        self.unit = unit?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.cycleFlow = cycleFlow
        self.symptoms = symptoms.sorted { $0.rawValue < $1.rawValue }
        self.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func completion(note: String = "") -> TrackingPayload {
        TrackingPayload(kind: .completion, note: note)
    }

    public static func medication(
        status: MedicationStatus,
        dose: Double? = nil,
        unit: String? = nil,
        note: String = ""
    ) -> TrackingPayload {
        TrackingPayload(
            kind: .medication,
            medicationStatus: status,
            dose: dose,
            unit: unit,
            note: note
        )
    }

    public static func cycle(
        flow: CycleFlow,
        symptoms: [CycleSymptom] = [],
        note: String = ""
    ) -> TrackingPayload {
        TrackingPayload(
            kind: .cycle,
            cycleFlow: flow,
            symptoms: symptoms,
            note: note
        )
    }

    public static func note(_ text: String) -> TrackingPayload {
        TrackingPayload(kind: .note, note: text)
    }

    public static func defaultPayload(for trackerKind: TrackerKind) -> TrackingPayload {
        switch trackerKind {
        case .habit:
            .completion()
        case .medication:
            .medication(status: .taken)
        case .cycle:
            .cycle(flow: .medium)
        case .custom:
            .note("")
        }
    }

    public var summary: String {
        switch kind {
        case .completion:
            return join(parts: ["已完成", note])
        case .medication:
            return join(parts: [
                medicationStatus?.title ?? "已记录",
                formattedDose,
                note
            ])
        case .cycle:
            return join(parts: [
                cycleFlow?.title ?? "已记录",
                symptoms.isEmpty ? "" : symptoms.map(\.title).joined(separator: "、"),
                note
            ])
        case .note:
            return note.isEmpty ? "已记录" : note
        }
    }

    public var countsAsCompletion: Bool {
        switch kind {
        case .completion:
            true
        case .medication:
            medicationStatus == .taken
        case .cycle:
            true
        case .note:
            true
        }
    }

    private var formattedDose: String {
        guard let dose else { return "" }

        let value: String
        if dose.rounded(.towardZero) == dose {
            value = String(Int(dose))
        } else {
            value = String(dose)
        }

        if let unit, !unit.isEmpty {
            return "\(value) \(unit)"
        }

        return value
    }

    private func join(parts: [String]) -> String {
        parts.filter { !$0.isEmpty }.joined(separator: " · ")
    }
}
