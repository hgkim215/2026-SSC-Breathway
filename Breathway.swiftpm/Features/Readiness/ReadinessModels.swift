import Foundation

enum ReadinessLevel: Int, CaseIterable, Identifiable {
    case none = 0
    case mild = 1
    case moderate = 2
    case severe = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .none: "None"
        case .mild: "Mild"
        case .moderate: "Moderate"
        case .severe: "Severe"
        }
    }

    var next: ReadinessLevel {
        ReadinessLevel(rawValue: min(rawValue + 1, ReadinessLevel.severe.rawValue)) ?? .severe
    }

    var previous: ReadinessLevel {
        ReadinessLevel(rawValue: max(rawValue - 1, ReadinessLevel.none.rawValue)) ?? .none
    }
}

enum ReadinessDomain: CaseIterable, Identifiable {
    case breathlessness
    case fatigue
    case confidence

    var id: String { title }

    var title: String {
        switch self {
        case .breathlessness: "Breathlessness"
        case .fatigue: "Fatigue"
        case .confidence: "Confidence"
        }
    }

    var symbolName: String {
        switch self {
        case .breathlessness: "wind"
        case .fatigue: "figure.walk"
        case .confidence: "ferry"
        }
    }
}

enum SessionRecommendation: Equatable {
    case light
    case standard

    var label: String {
        switch self {
        case .light: "Light"
        case .standard: "Standard"
        }
    }
}

enum GuidanceTone {
    case supportive
    case safety
}

struct ReadinessSelectionState: Equatable {
    var breathlessness: ReadinessLevel
    var fatigue: ReadinessLevel
    var confidence: ReadinessLevel

    static let `default` = ReadinessSelectionState(
        breathlessness: .moderate,
        fatigue: .mild,
        confidence: .moderate
    )

    var hasSevere: Bool {
        breathlessness == .severe || fatigue == .severe || confidence == .severe
    }

    subscript(domain: ReadinessDomain) -> ReadinessLevel {
        get {
            switch domain {
            case .breathlessness: breathlessness
            case .fatigue: fatigue
            case .confidence: confidence
            }
        }
        set {
            switch domain {
            case .breathlessness: breathlessness = newValue
            case .fatigue: fatigue = newValue
            case .confidence: confidence = newValue
            }
        }
    }
}

struct ReadinessScoreContext {
    var last7CompletionRate: Double
    var lastRPEAfter: Int
    var consecutiveSafetyStops: Int

    static let `default` = ReadinessScoreContext(
        last7CompletionRate: 0.60,
        lastRPEAfter: 5,
        consecutiveSafetyStops: 0
    )
}
