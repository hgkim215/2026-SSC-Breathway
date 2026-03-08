import Foundation

struct SessionIntensityProfile: Equatable, Sendable {
    let recommendation: SessionRecommendation
    let breathConfig: BreathSessionConfig
    let moveConfig: MoveSessionConfig

    var displayName: String {
        switch recommendation {
        case .light:
            "Light Session"
        case .standard:
            "Standard Session"
        }
    }

    var breathingSummaryText: String {
        "60 sec · Inhale \(secondsLabel(breathConfig.inhaleSeconds))s / Exhale \(secondsLabel(breathConfig.exhaleSeconds))s"
    }

    var moveSummaryText: String {
        "90 sec · Stand \(secondsLabel(moveConfig.exhaleSeconds))s + Sit \(secondsLabel(moveConfig.inhaleSeconds))s · Goal \(moveConfig.targetReps) reps"
    }

    var coachingSummaryText: String {
        switch recommendation {
        case .light:
            "Cue: stay in Gentle to Steady. Avoid strong pushes."
        case .standard:
            "Cue: keep a steady rhythm and smooth transitions."
        }
    }

    var safetySummaryText: String? {
        switch recommendation {
        case .light:
            "Armrests and partial range are okay. Skip move is logged as a safe completion."
        case .standard:
            nil
        }
    }

    var breathingCycleSecondsLabel: String {
        secondsLabel(breathConfig.cycleSeconds)
    }

    var moveRepSecondsLabel: String {
        secondsLabel(moveConfig.cycleSeconds)
    }

    var repRhythmHintText: String {
        "1 rep = stand \(secondsLabel(moveConfig.exhaleSeconds)) sec + sit \(secondsLabel(moveConfig.inhaleSeconds)) sec"
    }

    var breathInhaleSecondsLabel: String { secondsLabel(breathConfig.inhaleSeconds) }
    var breathExhaleSecondsLabel: String { secondsLabel(breathConfig.exhaleSeconds) }
    var moveStandSecondsLabel: String { secondsLabel(moveConfig.exhaleSeconds) }
    var moveSitSecondsLabel: String { secondsLabel(moveConfig.inhaleSeconds) }

    private func secondsLabel(_ value: Double) -> String {
        let rounded = value.rounded()
        if abs(rounded - value) < 0.001 {
            return String(Int(rounded))
        }
        return String(format: "%.1f", value)
    }
}

extension SessionRecommendation {
    var intensityProfile: SessionIntensityProfile {
        switch self {
        case .light:
            return SessionIntensityProfile(
                recommendation: .light,
                breathConfig: BreathSessionConfig(
                    total: .seconds(60),
                    inhale: .seconds(5),
                    exhale: .seconds(5),
                    sampleInterval: .milliseconds(50)
                ),
                moveConfig: MoveSessionConfig(
                    total: .seconds(90),
                    inhale: .seconds(5),
                    exhale: .seconds(4),
                    sampleInterval: .milliseconds(50),
                    targetReps: 10
                )
            )
        case .standard:
            return SessionIntensityProfile(
                recommendation: .standard,
                breathConfig: BreathSessionConfig(
                    total: .seconds(60),
                    inhale: .seconds(4),
                    exhale: .seconds(6),
                    sampleInterval: .milliseconds(50)
                ),
                moveConfig: MoveSessionConfig(
                    total: .seconds(90),
                    inhale: .seconds(3),
                    exhale: .seconds(3),
                    sampleInterval: .milliseconds(50),
                    targetReps: 15
                )
            )
        }
    }
}
