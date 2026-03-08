import Foundation

@MainActor
final class MoveSessionEngine {
    struct EventCallbacks {
        var onStarted: (() -> Void)?
        var onCompleted: ((MoveSessionSummary) -> Void)?
        var onStoppedForSafety: (() -> Void)?
    }

    var onSnapshot: ((MoveSessionSnapshot) -> Void)?
    var events = EventCallbacks()

    private let config: MoveSessionConfig
    private let clock = ContinuousClock()

    private(set) var state: MoveSessionState = .idle
    private var startInstant: ContinuousClock.Instant?
    private var pauseInstant: ContinuousClock.Instant?
    private var accumulatedPauseDuration: Duration = .zero
    private var updateTask: Task<Void, Never>?
    private var completionReason: MoveCompletionReason?

    init(config: MoveSessionConfig = .init()) {
        self.config = config
    }

    func start() {
        stopUpdateLoop()
        resetSession()
        startInstant = clock.now
        transition(to: .running)
        events.onStarted?()
        publishSnapshot(elapsedSec: 0)
        startUpdateLoop()
    }

    func togglePause() {
        if pauseIfRunning() {
            return
        }
        _ = resumeIfPaused()
    }

    @discardableResult
    func pauseIfRunning() -> Bool {
        guard state == .running else { return false }
        pauseInstant = clock.now
        transition(to: .paused)
        stopUpdateLoop()
        publishSnapshot(elapsedSec: min(currentElapsedSeconds(), config.totalSeconds))
        return true
    }

    @discardableResult
    func resumeIfPaused() -> Bool {
        guard state == .paused else { return false }
        if let pauseInstant {
            accumulatedPauseDuration += pauseInstant.duration(to: clock.now)
        }
        self.pauseInstant = nil
        transition(to: .running)
        startUpdateLoop()
        return true
    }

    func endEarly() {
        guard state == .running || state == .paused else { return }
        completeSession(reason: .endedEarly, elapsedSec: min(currentElapsedSeconds(), config.totalSeconds))
    }

    func stopForSafety() {
        guard state == .running || state == .paused else { return }
        transition(to: .stoppedForSafety)
        stopUpdateLoop()
        publishSnapshot(elapsedSec: min(currentElapsedSeconds(), config.totalSeconds))
        events.onStoppedForSafety?()
    }

    func finishIfNeededForNavigation() {
        guard state == .completed else { return }
        stopUpdateLoop()
    }

    private func startUpdateLoop() {
        let interval = config.sampleInterval
        updateTask = Task { [weak self, interval] in
            while !Task.isCancelled {
                self?.tick()
                try? await Task.sleep(for: interval)
            }
        }
    }

    private func stopUpdateLoop() {
        updateTask?.cancel()
        updateTask = nil
    }

    private func tick() {
        guard state == .running else { return }
        let elapsedSec = min(currentElapsedSeconds(), config.totalSeconds)
        publishSnapshot(elapsedSec: elapsedSec)

        if elapsedSec >= config.totalSeconds {
            completeSession(reason: .completedByTimer, elapsedSec: config.totalSeconds)
        }
    }

    private func completeSession(reason: MoveCompletionReason, elapsedSec: Double) {
        completionReason = reason
        transition(to: .completed)
        stopUpdateLoop()

        let clampedElapsed = min(max(0, elapsedSec), config.totalSeconds)
        let completedRepCount: Int
        if reason == .completedByTimer {
            completedRepCount = config.targetReps
        } else {
            completedRepCount = completedReps(for: clampedElapsed)
        }

        let summary = MoveSessionSummary(
            completionReason: reason,
            durationSec: clampedElapsed,
            completedReps: completedRepCount,
            targetReps: config.targetReps
        )

        publishSnapshot(
            elapsedSec: clampedElapsed,
            completionReason: reason,
            forcedCompletedReps: completedRepCount
        )
        events.onCompleted?(summary)
    }

    private func transition(to newState: MoveSessionState) {
        state = newState
    }

    private func resetSession() {
        state = .idle
        startInstant = nil
        pauseInstant = nil
        accumulatedPauseDuration = .zero
        completionReason = nil
    }

    private func currentElapsedSeconds() -> Double {
        guard let startInstant else { return 0 }

        let now = clock.now
        var pausedDuration = accumulatedPauseDuration
        if state == .paused, let pauseInstant {
            pausedDuration += pauseInstant.duration(to: now)
        }

        let active = startInstant.duration(to: now) - pausedDuration
        return max(0, active.toSeconds)
    }

    private func phaseInfo(for elapsedSec: Double) -> (phase: MovePhase, progress: Double) {
        let cycleSeconds = max(config.cycleSeconds, 0.001)
        let offset = elapsedSec.truncatingRemainder(dividingBy: cycleSeconds)

        if offset < config.exhaleSeconds {
            return (.exhaleStand, clamp(offset / max(config.exhaleSeconds, 0.001)))
        }

        let inhaleOffset = offset - config.exhaleSeconds
        return (.inhaleSit, clamp(inhaleOffset / max(config.inhaleSeconds, 0.001)))
    }

    private func completedReps(for elapsedSec: Double) -> Int {
        guard config.targetReps > 0 else { return 0 }
        let cycles = Int(floor(elapsedSec / max(config.cycleSeconds, 0.001)))
        return min(config.targetReps, max(0, cycles))
    }

    private func publishSnapshot(
        elapsedSec: Double,
        completionReason: MoveCompletionReason? = nil,
        forcedCompletedReps: Int? = nil
    ) {
        let phaseInfo = phaseInfo(for: elapsedSec)
        let reason = completionReason ?? self.completionReason

        let completedReps = forcedCompletedReps ?? completedReps(for: elapsedSec)
        let normalizedReps = min(config.targetReps, max(0, completedReps))
        let repsLeft = max(0, config.targetReps - normalizedReps)
        let timeProgressRatio = clamp(elapsedSec / max(config.totalSeconds, 0.001))
        let progressRatio = Double(normalizedReps) / Double(max(config.targetReps, 1))
        let beaconLitCount: Int = {
            if normalizedReps == 0 {
                return 0
            }
            if reason == .completedByTimer {
                return 5
            }
            let ratio = Double(normalizedReps) / Double(max(config.targetReps, 1))
            return min(5, max(1, Int(ceil(ratio * 5.0))))
        }()

        onSnapshot?(
            MoveSessionSnapshot(
                state: state,
                phase: phaseInfo.phase,
                phaseProgress: phaseInfo.progress,
                elapsedSec: elapsedSec,
                remainingSec: max(0, config.totalSeconds - elapsedSec),
                totalSec: config.totalSeconds,
                completedReps: normalizedReps,
                targetReps: config.targetReps,
                repsLeft: repsLeft,
                timeProgressRatio: timeProgressRatio,
                progressRatio: progressRatio,
                beaconLitCount: beaconLitCount,
                completionReason: reason
            )
        )
    }

    private func clamp(_ value: Double, min lower: Double = 0, max upper: Double = 1) -> Double {
        Swift.min(Swift.max(value, lower), upper)
    }
}
