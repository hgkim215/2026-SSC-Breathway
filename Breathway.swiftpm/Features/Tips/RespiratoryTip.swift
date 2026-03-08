import Foundation

struct RespiratoryTip: Equatable {
    enum Source: String {
        case foundationModel = "AI"
        case fallback = "Built-in"
    }

    let headline: String
    let body: String
    let safetyNote: String
    let generatedAt: Date
    let source: Source
}

enum RespiratoryTipContext: Equatable {
    case homeMission
    case resultRecovery(isMoveCompleted: Bool)
    case progressMotivation(weekCompletionRate: Double, streakCount: Int, safetyStopsThisWeek: Int)

    var promptContext: String {
        switch self {
        case .homeMission:
            return "Home mission card before the user starts today's short routine"
        case .resultRecovery(let isMoveCompleted):
            return isMoveCompleted
                ? "Session result after breathing + movement completed"
                : "Session result after an early safe stop"
        case .progressMotivation(let weekCompletionRate, let streakCount, let safetyStopsThisWeek):
            let completionPercent = Int((weekCompletionRate * 100).rounded())
            return """
            Progress screen after weekly summary.
            Weekly completion: \(completionPercent)%.
            Current streak: \(streakCount) days.
            Safety stops this week: \(safetyStopsThisWeek).
            Generate one short motivational message for consistency.
            """
        }
    }

    var fallbackPool: [RespiratoryTip] {
        switch self {
        case .homeMission:
            return Self.homeFallbackTips
        case .resultRecovery(let isMoveCompleted):
            return isMoveCompleted ? Self.resultCompletedFallbackTips : Self.resultEarlyStopFallbackTips
        case .progressMotivation:
            return Self.progressFallbackTips
        }
    }

    private static let homeFallbackTips: [RespiratoryTip] = [
        RespiratoryTip(
            headline: "Set your chair first",
            body: "Place a stable chair before starting, so movement starts smoothly after breathing.",
            safetyNote: "Pause if your breathing feels sharper than usual.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Exhale on effort",
            body: "During sit-to-stand, breathe out while standing up to reduce chest tension.",
            safetyNote: "Stop if dizziness appears, then rest with slow breathing.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Keep steps tiny",
            body: "Focus on one calm cycle at a time instead of rushing all reps at once.",
            safetyNote: "Comfort and control are more important than speed.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Shoulders down",
            body: "Relax your shoulders during inhale and exhale to avoid unnecessary strain.",
            safetyNote: "If chest discomfort starts, end the session and rest.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Use a steady rhythm",
            body: "Try matching movement to your cue timing instead of forcing bigger motions.",
            safetyNote: "Skip movement when symptoms increase unexpectedly.",
            generatedAt: .distantPast,
            source: .fallback
        )
    ]

    private static let resultCompletedFallbackTips: [RespiratoryTip] = [
        RespiratoryTip(
            headline: "Cool down gently",
            body: "Take 2 calm minutes before standing up for other tasks.",
            safetyNote: "Hydrate if your throat feels dry after the session.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Keep the win small",
            body: "A short completed routine is enough to build consistency over time.",
            safetyNote: "Stop future sessions early if warning symptoms return.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Log your feeling",
            body: "Write one short note about breathing comfort to guide tomorrow's pace.",
            safetyNote: "Choose lighter effort if recovery feels slower than usual.",
            generatedAt: .distantPast,
            source: .fallback
        )
    ]

    private static let resultEarlyStopFallbackTips: [RespiratoryTip] = [
        RespiratoryTip(
            headline: "Safety stop is progress",
            body: "Stopping early when symptoms rise protects consistency for tomorrow.",
            safetyNote: "Resume only when breathing feels settled again.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Return to calm breaths",
            body: "Use slower exhale cycles while seated until your breathing steadies.",
            safetyNote: "Seek medical help if severe symptoms do not ease.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Reset the next session",
            body: "Try a lighter pace next time and keep movement range gentle.",
            safetyNote: "Your safety decision is the correct decision.",
            generatedAt: .distantPast,
            source: .fallback
        )
    ]

    private static let progressFallbackTips: [RespiratoryTip] = [
        RespiratoryTip(
            headline: "Consistency beats intensity",
            body: "A short, steady session today is enough to keep recovery momentum moving forward.",
            safetyNote: "Choose comfort-first pacing whenever symptoms feel stronger than usual.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Small wins build capacity",
            body: "Your weekly pattern matters most, so protect rhythm with calm, repeatable effort.",
            safetyNote: "Pause and recover first if breathing feels unstable.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Steady days add up",
            body: "Keep each session manageable so tomorrow still feels possible and safe.",
            safetyNote: "Use a lighter session whenever discomfort rises.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Protect the next session",
            body: "Finish with control today to make returning tomorrow easier.",
            safetyNote: "Stop early when warning signs appear.",
            generatedAt: .distantPast,
            source: .fallback
        ),
        RespiratoryTip(
            headline: "Your pace is the plan",
            body: "Progress grows when breathing stays smooth and movement stays controlled.",
            safetyNote: "Safety choices are always valid progress.",
            generatedAt: .distantPast,
            source: .fallback
        )
    ]
}

enum RespiratoryTipState: Equatable {
    case idle
    case loading
    case loaded(RespiratoryTip)
}
