import Foundation

enum BreathPhase: String, Equatable, Sendable {
    case inhale
    case exhale

    var title: String {
        switch self {
        case .inhale: "INHALE"
        case .exhale: "EXHALE"
        }
    }

    var guidance: String {
        switch self {
        case .inhale: "Breathe in slowly\nthrough your nose."
        case .exhale: "Breathe out slowly\nthrough your mouth."
        }
    }
}

enum BreathBand: String, CaseIterable, Equatable, Sendable {
    case gentle
    case steady
    case strong

    var title: String {
        rawValue.capitalized
    }
}

enum BreathCaptureMode: String, Equatable, Sendable {
    case microphone
    case rhythmOnly
}

enum BreathingSessionState: Equatable, Sendable {
    case idle
    case preflight
    case running
    case paused
    case completed
    case stoppedForSafety
}

struct BreathSessionConfig: Equatable, Sendable {
    var total: Duration = .seconds(60)
    var inhale: Duration = .seconds(4)
    var exhale: Duration = .seconds(6)
    var sampleInterval: Duration = .milliseconds(50)

    var cycle: Duration { inhale + exhale }
    var totalSeconds: Double { total.toSeconds }
    var inhaleSeconds: Double { inhale.toSeconds }
    var exhaleSeconds: Double { exhale.toSeconds }
    var cycleSeconds: Double { cycle.toSeconds }
}

struct BreathIntensitySummary: Equatable, Sendable {
    let avgInhaleEffort: Double
    let avgExhaleEffort: Double
    let timeInSteadyBandSec: Double
}

struct BreathEffortSample: Equatable, Sendable {
    let elapsed: Duration
    let phase: BreathPhase
    let effort: Double
    let band: BreathBand
    let mode: BreathCaptureMode
}

struct BreathingSessionSnapshot: Equatable, Sendable {
    let state: BreathingSessionState
    let mode: BreathCaptureMode
    let phase: BreathPhase
    let phaseProgress: Double
    let elapsedSec: Double
    let remainingSec: Double
    let cycleIndex: Int
    let cycleCount: Int
    let effort: Double
    let rawBand: BreathBand
    let stableBand: BreathBand
    let steadyRunSec: Double
    let isCalibrating: Bool
}

extension Duration {
    var toSeconds: Double {
        let components = self.components
        return Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
