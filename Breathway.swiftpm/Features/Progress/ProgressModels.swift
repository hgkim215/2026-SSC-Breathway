import Foundation

enum ProgressSessionKind: String, Codable, Sendable {
    case breathing
    case move

    var title: String {
        switch self {
        case .breathing: "Breathing"
        case .move: "Sit-to-Stand"
        }
    }
}

enum ProgressSessionOutcome: String, Codable, Sendable {
    case completed
    case endedEarly
    case safetyStop
}

struct ProgressSessionEvent: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let kind: ProgressSessionKind
    let outcome: ProgressSessionOutcome
    let durationSec: Double?
    let recommendationLabel: String?
    let reason: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        kind: ProgressSessionKind,
        outcome: ProgressSessionOutcome,
        durationSec: Double? = nil,
        recommendationLabel: String? = nil,
        reason: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kind = kind
        self.outcome = outcome
        self.durationSec = durationSec
        self.recommendationLabel = recommendationLabel
        self.reason = reason
    }
}

struct ProgressViewData {
    let streakText: String
    let dateText: String
    let weekCompletedText: String
    let weekCompletionText: String
    let weekProgressRatio: Double
    let currentStreakCount: Int
    let currentStreakValueText: String
    let safetyStopsValueText: String
    let safetyStopsThisWeek: Int
    let safetyLogLines: [String]
    let weekDays: [WeekDayProgress]
    let disclaimerLines: [String]

    static let placeholder = ProgressViewData(
        streakText: "🔥 0-Day Streak",
        dateText: "--",
        weekCompletedText: "0 / 7 days",
        weekCompletionText: "Week Completion: 0%",
        weekProgressRatio: 0,
        currentStreakCount: 0,
        currentStreakValueText: "0 Days",
        safetyStopsValueText: "0 this week",
        safetyStopsThisWeek: 0,
        safetyLogLines: ["• No safety stops logged this week."],
        weekDays: [],
        disclaimerLines: [
            "You can skip movement anytime for safety.",
            "Your progress and safety logs stay on this iPad."
        ]
    )
}
