import Foundation

enum MovePhase: String, Equatable, Sendable {
    case inhaleSit
    case exhaleStand

    var subtitle: String {
        switch self {
        case .inhaleSit: "Inhale, sit."
        case .exhaleStand: "Exhale, stand."
        }
    }

    var cueTitle: String {
        switch self {
        case .inhaleSit: "NOW INHALE"
        case .exhaleStand: "NOW EXHALE"
        }
    }

    var cueInstruction: String {
        switch self {
        case .inhaleSit: "Sit down slowly"
        case .exhaleStand: "Stand up"
        }
    }
}

enum MoveSessionState: Equatable, Sendable {
    case idle
    case running
    case paused
    case completed
    case stoppedForSafety
}

enum MoveCompletionReason: String, Equatable, Sendable {
    case completedByTimer
    case endedEarly
}

struct MoveSessionConfig: Equatable, Sendable {
    var total: Duration = .seconds(90)
    var inhale: Duration = .seconds(3)
    var exhale: Duration = .seconds(3)
    var sampleInterval: Duration = .milliseconds(50)
    var targetReps: Int = 15

    var totalSeconds: Double { total.toSeconds }
    var inhaleSeconds: Double { inhale.toSeconds }
    var exhaleSeconds: Double { exhale.toSeconds }
    var cycleSeconds: Double { inhaleSeconds + exhaleSeconds }
}

struct MoveSessionSummary: Equatable, Sendable {
    let completionReason: MoveCompletionReason
    let durationSec: Double
    let completedReps: Int
    let targetReps: Int
}

struct MoveSessionSnapshot: Equatable, Sendable {
    let state: MoveSessionState
    let phase: MovePhase
    let phaseProgress: Double
    let elapsedSec: Double
    let remainingSec: Double
    let totalSec: Double
    let completedReps: Int
    let targetReps: Int
    let repsLeft: Int
    let timeProgressRatio: Double
    let progressRatio: Double
    let beaconLitCount: Int
    let completionReason: MoveCompletionReason?
}
