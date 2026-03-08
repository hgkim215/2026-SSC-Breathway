import Foundation

@MainActor
final class MovePlayViewModel: ObservableObject {
    @Published private(set) var snapshot: MoveSessionSnapshot
    @Published private(set) var summary: MoveSessionSummary?
    @Published private(set) var phaseHapticTrigger = 0
    @Published private(set) var completionHapticTrigger = 0
    @Published private(set) var safetyHapticTrigger = 0
    let recommendation: SessionRecommendation

    var onSafetyStop: (() -> Void)?
    var onFinishMission: ((MoveSessionSummary) -> Void)?
    var onExitToHomeRequested: (() -> Void)?

    private let engine: MoveSessionEngine
    private let config: MoveSessionConfig
    private var hasStarted = false
    private var lastPhase: MovePhase = .exhaleStand

    init(
        recommendation: SessionRecommendation = .standard,
        config: MoveSessionConfig = .init(),
        engine: MoveSessionEngine? = nil
    ) {
        self.recommendation = recommendation
        self.config = config
        self.engine = engine ?? MoveSessionEngine(config: config)
        self.snapshot = Self.defaultSnapshot(config: config)
        bindEngine()
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        engine.start()
    }

    func pauseResumeTapped() {
        engine.togglePause()
    }

    func pauseForQuickReminderIfNeeded() -> Bool {
        engine.pauseIfRunning()
    }

    func resumeAfterQuickReminderIfNeeded(_ autoPaused: Bool) {
        guard autoPaused, snapshot.state == .paused else { return }
        _ = engine.resumeIfPaused()
    }

    func endTapped() {
        engine.endEarly()
    }

    func requestStopToHome() {
        guard snapshot.state == .running || snapshot.state == .paused else {
            onExitToHomeRequested?()
            return
        }

        engine.stopForSafety()
        onExitToHomeRequested?()
    }

    @discardableResult
    func openRecoveryGuideFromNeedRest() -> Bool {
        guard snapshot.state == .running || snapshot.state == .paused else { return false }
        _ = engine.pauseIfRunning()
        return true
    }

    func resumeAfterRecoveryGuide() {
        _ = engine.resumeIfPaused()
    }

    func exitToHomeFromRecoveryGuide() {
        engine.stopForSafety()
        onExitToHomeRequested?()
    }

    func finishTappedFromResult() {
        guard let summary else { return }
        onFinishMission?(summary)
    }

    func viewDidDisappear() {
        engine.finishIfNeededForNavigation()
    }

    var pauseButtonLabel: String {
        snapshot.state == .paused ? "Resume" : "Pause"
    }

    var pauseButtonIcon: String {
        snapshot.state == .paused ? "▶" : "Ⅱ"
    }

    var repsValueText: String {
        "\(snapshot.completedReps) / \(snapshot.targetReps)"
    }

    var repsLeftText: String {
        snapshot.repsLeft > 0 ? "\(snapshot.repsLeft) left" : "Goal reached"
    }

    var goalHintText: String {
        if let summary {
            return "Session \(timeString(summary.durationSec))"
        }
        return "Goal \(snapshot.targetReps) reps"
    }

    var repRhythmHintText: String {
        "1 rep = stand \(secondsLabel(config.exhaleSeconds)) sec + sit \(secondsLabel(config.inhaleSeconds)) sec"
    }

    var resultHeadline: String {
        switch summary?.completionReason {
        case .endedEarly:
            "You ended this movement set early.\nTake your pace and continue when ready."
        case .completedByTimer, .none:
            "You finished the movement set safely.\nReview your result and continue at your pace."
        }
    }

    var resultCueTitle: String {
        switch summary?.completionReason {
        case .endedEarly: "Session ended early."
        case .completedByTimer, .none: "Session complete."
        }
    }

    var resultCueSubtitle: String {
        switch summary?.completionReason {
        case .endedEarly: "You can rest now and continue later."
        case .completedByTimer, .none: "You can repeat, go home, or finish for today."
        }
    }

    var resultRouteHint: String {
        switch summary?.completionReason {
        case .endedEarly:
            "You paused your route safely. Return when breathing feels steady."
        case .completedByTimer, .none:
            "All beacons are lit. You reached home with steady breathing."
        }
    }

    var isShowingResult: Bool {
        snapshot.state == .completed && summary != nil
    }

    private func bindEngine() {
        engine.onSnapshot = { [weak self] snapshot in
            guard let self else { return }
            if snapshot.phase != self.lastPhase {
                self.phaseHapticTrigger += 1
                self.lastPhase = snapshot.phase
            }
            self.snapshot = snapshot
        }

        engine.events.onCompleted = { [weak self] summary in
            guard let self else { return }
            self.summary = summary
            self.completionHapticTrigger += 1
        }

        engine.events.onStoppedForSafety = { [weak self] in
            guard let self else { return }
            self.safetyHapticTrigger += 1
            self.onSafetyStop?()
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let clamped = max(0, Int(seconds.rounded(.down)))
        let minute = clamped / 60
        let second = clamped % 60
        return "\(minute):" + String(format: "%02d", second)
    }

    private func secondsLabel(_ value: Double) -> String {
        let rounded = value.rounded()
        if abs(rounded - value) < 0.001 {
            return String(Int(rounded))
        }
        return String(format: "%.1f", value)
    }

    private static func defaultSnapshot(config: MoveSessionConfig) -> MoveSessionSnapshot {
        let totalSeconds = config.totalSeconds
        let targetReps = max(config.targetReps, 0)
        return MoveSessionSnapshot(
            state: .idle,
            phase: .exhaleStand,
            phaseProgress: 0,
            elapsedSec: 0,
            remainingSec: totalSeconds,
            totalSec: totalSeconds,
            completedReps: 0,
            targetReps: targetReps,
            repsLeft: targetReps,
            timeProgressRatio: 0,
            progressRatio: 0,
            beaconLitCount: 0,
            completionReason: nil
        )
    }
}
