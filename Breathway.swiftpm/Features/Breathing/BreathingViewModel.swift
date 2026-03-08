import Foundation

@MainActor
final class BreathingViewModel: ObservableObject {
    @Published private(set) var snapshot: BreathingSessionSnapshot
    @Published private(set) var summary: BreathIntensitySummary?
    @Published private(set) var phaseHapticTrigger = 0
    @Published private(set) var steadyHapticTrigger = 0
    @Published private(set) var safetyHapticTrigger = 0

    let recommendation: SessionRecommendation

    var onSafetyStop: (() -> Void)?
    var onCompleted: ((BreathIntensitySummary) -> Void)?
    var onExitToHomeRequested: (() -> Void)?
    private let engine: BreathingSessionEngine
    private let analyticsLogger: AnalyticsLogger
    private var hasStarted = false
    private var lastPhase: BreathPhase = .inhale
    private var skipTransitionTriggered = false
    private var pendingRecoveryStopReason: String?

    init(
        recommendation: SessionRecommendation,
        engine: BreathingSessionEngine = BreathingSessionEngine(),
        analyticsLogger: AnalyticsLogger = AnalyticsLogger()
    ) {
        self.recommendation = recommendation
        self.engine = engine
        self.analyticsLogger = analyticsLogger
        self.snapshot = Self.defaultSnapshot
        bindEngine()
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        Task { [weak self] in
            await self?.engine.start()
        }
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

    @discardableResult
    func openRecoveryGuideForSafety(reason: String) -> Bool {
        guard snapshot.state == .running || snapshot.state == .paused else { return false }
        pendingRecoveryStopReason = reason
        _ = engine.pauseIfRunning()
        return true
    }

    func resumeAfterRecoveryGuide() {
        _ = engine.resumeIfPaused()
    }

    func exitToHomeFromRecoveryGuide() {
        guard snapshot.state == .running || snapshot.state == .paused else {
            onExitToHomeRequested?()
            return
        }

        let reason = pendingRecoveryStopReason ?? "recovery_back_home"
        analyticsLogger.trackMissionStoppedForSafety(reason: reason, elapsedSec: snapshot.elapsedSec, mode: snapshot.mode)
        pendingRecoveryStopReason = nil
        engine.stopForSafety()
        onExitToHomeRequested?()
    }

    @discardableResult
    func skipToMoveGuideTapped() -> Bool {
        guard !skipTransitionTriggered else { return false }
        guard snapshot.state == .running || snapshot.state == .paused || snapshot.state == .preflight else { return false }
        skipTransitionTriggered = true
        engine.stopForMoveGuideTransition()
        return true
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

    func requestStopToHome() {
        guard snapshot.state == .running || snapshot.state == .paused else {
            onExitToHomeRequested?()
            return
        }

        analyticsLogger.trackMissionStoppedForSafety(
            reason: "stop_confirm_exit",
            elapsedSec: snapshot.elapsedSec,
            mode: snapshot.mode
        )
        engine.stopForSafety()
        onExitToHomeRequested?()
    }

    var waveTitle: String {
        switch snapshot.phase {
        case .inhale: "BREATH SHADOW WAVE"
        case .exhale: "BREATH LIGHT WAVE"
        }
    }

    var waveHint: String {
        switch snapshot.phase {
        case .inhale: "Inhale deeper to dim the beacon"
        case .exhale: "Exhale stronger to amplify light"
        }
    }

    var waveMetricText: String {
        let litersPerMinute = Int((snapshot.effort * 18).rounded())
        return "\(snapshot.stableBand.title) · \(litersPerMinute) L/min"
    }

    var timerText: String {
        let elapsed = timeString(snapshot.elapsedSec)
        let total = timeString(snapshot.elapsedSec + snapshot.remainingSec)
        return "\(elapsed) / \(total)"
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

        engine.events.onStarted = { [weak self] mode in
            self?.analyticsLogger.trackBreathingPlayStarted(mode: mode, recommendation: self?.recommendation ?? .standard)
        }

        engine.events.onBandChanged = { [weak self] previous, next, elapsed, mode in
            self?.analyticsLogger.trackBreathEffortBandChanged(
                previousBand: previous,
                newBand: next,
                elapsedSec: elapsed,
                mode: mode
            )
        }

        engine.events.onSteadyStreakAchieved = { [weak self] streakSec, mode in
            guard let self else { return }
            self.steadyHapticTrigger += 1
            self.analyticsLogger.trackSteadyStreakAchieved(steadyRunSec: streakSec, elapsedSec: self.snapshot.elapsedSec, mode: mode)
        }

        engine.events.onCompleted = { [weak self] summary, mode in
            guard let self else { return }
            self.summary = summary
            self.analyticsLogger.trackBreathingPlayCompleted(
                durationSec: self.snapshot.elapsedSec,
                summary: summary,
                mode: mode
            )
            self.onCompleted?(summary)
        }

        engine.events.onStoppedForSafety = { [weak self] _ in
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

    private static var defaultSnapshot: BreathingSessionSnapshot {
        BreathingSessionSnapshot(
            state: .idle,
            mode: .rhythmOnly,
            phase: .inhale,
            phaseProgress: 0,
            elapsedSec: 0,
            remainingSec: 60,
            cycleIndex: 1,
            cycleCount: 6,
            effort: 0.4,
            rawBand: .gentle,
            stableBand: .gentle,
            steadyRunSec: 0,
            isCalibrating: false
        )
    }
}
