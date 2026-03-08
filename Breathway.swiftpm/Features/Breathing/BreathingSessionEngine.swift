import Foundation

@MainActor
final class BreathingSessionEngine {
    struct EventCallbacks {
        var onStarted: ((BreathCaptureMode) -> Void)?
        var onBandChanged: ((BreathBand, BreathBand, Double, BreathCaptureMode) -> Void)?
        var onSteadyStreakAchieved: ((Double, BreathCaptureMode) -> Void)?
        var onCompleted: ((BreathIntensitySummary, BreathCaptureMode) -> Void)?
        var onStoppedForSafety: ((BreathCaptureMode) -> Void)?
    }

    var onSnapshot: ((BreathingSessionSnapshot) -> Void)?
    var events = EventCallbacks()

    private let config: BreathSessionConfig
    private let audioProvider: BreathingAudioSignalProviding
    private let clock = ContinuousClock()

    private(set) var state: BreathingSessionState = .idle
    private(set) var mode: BreathCaptureMode = .rhythmOnly

    private var startInstant: ContinuousClock.Instant?
    private var pauseInstant: ContinuousClock.Instant?
    private var accumulatedPauseDuration: Duration = .zero
    private var updateTask: Task<Void, Never>?

    private var latestMicAmplitude: Double = 0
    private var emaAmplitude: Double = 0
    private let emaAlpha: Double = 0.25
    private var calibrationFloor: Double = .greatestFiniteMagnitude
    private var calibrationPeakRef: Double = 0
    private let calibrationWindowSec: Double = 6

    private var stableBand: BreathBand = .gentle
    private var pendingBand: BreathBand?
    private var pendingBandSince: Double = 0
    private let hysteresisSec: Double = 0.3

    private var steadyRunSec: Double = 0
    private var steadyAchievementEmitted = false

    private var inhaleEffortIntegral: Double = 0
    private var exhaleEffortIntegral: Double = 0
    private var inhaleDurationSec: Double = 0
    private var exhaleDurationSec: Double = 0
    private var steadyBandDurationSec: Double = 0
    private var lastElapsedSec: Double = 0

    init(
        config: BreathSessionConfig = .init(),
        audioProvider: BreathingAudioSignalProviding = BreathingAudioSignalProvider()
    ) {
        self.config = config
        self.audioProvider = audioProvider
        self.audioProvider.onAmplitude = { [weak self] amplitude in
            Task { @MainActor [weak self] in
                self?.latestMicAmplitude = amplitude
            }
        }
    }

    func start() async {
        stopUpdateLoop()
        resetSession()
        transition(to: .preflight)

        let permissionGranted = await audioProvider.requestPermission()
        if permissionGranted {
            do {
                try audioProvider.start()
                mode = .microphone
            } catch {
                mode = .rhythmOnly
            }
        } else {
            mode = .rhythmOnly
        }

        startInstant = clock.now
        transition(to: .running)
        events.onStarted?(mode)
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
        if mode == .microphone {
            audioProvider.stop()
        }
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
        if mode == .microphone {
            do {
                try audioProvider.start()
            } catch {
                mode = .rhythmOnly
            }
        }
        transition(to: .running)
        startUpdateLoop()
        return true
    }

    func stopForSafety() {
        guard state == .running || state == .paused else { return }
        transition(to: .stoppedForSafety)
        shutdownAudioAndTimer()
        events.onStoppedForSafety?(mode)
        publishSnapshot(elapsedSec: min(currentElapsedSeconds(), config.totalSeconds))
    }

    func finishIfNeededForNavigation() {
        guard state == .completed else { return }
        shutdownAudioAndTimer()
    }

    func stopForMoveGuideTransition() {
        guard state == .running || state == .paused || state == .preflight else { return }
        transition(to: .idle)
        shutdownAudioAndTimer()
        publishSnapshot(elapsedSec: min(currentElapsedSeconds(), config.totalSeconds))
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
        let deltaSec = max(0, elapsedSec - lastElapsedSec)
        lastElapsedSec = elapsedSec

        let phaseInfo = phaseInfo(for: elapsedSec)
        let effort = computeEffort(elapsedSec: elapsedSec, phase: phaseInfo.phase, phaseProgress: phaseInfo.progress)
        let rawBand = band(for: effort)
        let newStableBand = resolveStableBand(rawBand: rawBand, elapsedSec: elapsedSec)

        if deltaSec > 0 {
            accumulateSummary(
                phase: phaseInfo.phase,
                effort: effort,
                stableBand: newStableBand,
                deltaSec: deltaSec
            )
        }

        publishSnapshot(
            elapsedSec: elapsedSec,
            phase: phaseInfo.phase,
            phaseProgress: phaseInfo.progress,
            effort: effort,
            rawBand: rawBand,
            stableBand: newStableBand
        )

        if elapsedSec >= config.totalSeconds {
            completeSession()
        }
    }

    private func completeSession() {
        transition(to: .completed)
        shutdownAudioAndTimer()
        let summary = makeSummary()
        events.onCompleted?(summary, mode)
    }

    private func shutdownAudioAndTimer() {
        stopUpdateLoop()
        audioProvider.stop()
    }

    private func transition(to newState: BreathingSessionState) {
        state = newState
    }

    private func resetSession() {
        state = .idle
        mode = .rhythmOnly
        startInstant = nil
        pauseInstant = nil
        accumulatedPauseDuration = .zero
        latestMicAmplitude = 0
        emaAmplitude = 0
        calibrationFloor = .greatestFiniteMagnitude
        calibrationPeakRef = 0
        stableBand = .gentle
        pendingBand = nil
        pendingBandSince = 0
        steadyRunSec = 0
        steadyAchievementEmitted = false
        inhaleEffortIntegral = 0
        exhaleEffortIntegral = 0
        inhaleDurationSec = 0
        exhaleDurationSec = 0
        steadyBandDurationSec = 0
        lastElapsedSec = 0
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

    private func phaseInfo(for elapsedSec: Double) -> (phase: BreathPhase, progress: Double) {
        let offset = elapsedSec.truncatingRemainder(dividingBy: config.cycleSeconds)
        if offset < config.inhaleSeconds {
            return (.inhale, clamp(offset / max(config.inhaleSeconds, 0.001)))
        }

        let exhaleOffset = offset - config.inhaleSeconds
        return (.exhale, clamp(exhaleOffset / max(config.exhaleSeconds, 0.001)))
    }

    private func computeEffort(elapsedSec: Double, phase: BreathPhase, phaseProgress: Double) -> Double {
        if mode == .rhythmOnly {
            let wave = sin(phaseProgress * .pi)
            let base: Double = phase == .inhale ? 0.42 : 0.54
            let amplitude: Double = phase == .inhale ? 0.14 : 0.18
            return clamp(base + amplitude * wave)
        }

        let incomingAmplitude = max(latestMicAmplitude, 0)
        if emaAmplitude == 0 {
            emaAmplitude = incomingAmplitude
        } else {
            emaAmplitude = (emaAlpha * incomingAmplitude) + ((1 - emaAlpha) * emaAmplitude)
        }

        if elapsedSec <= calibrationWindowSec {
            calibrationFloor = min(calibrationFloor, emaAmplitude)
            calibrationPeakRef = max(calibrationPeakRef, emaAmplitude)
        }

        let floor = calibrationFloor.isFinite ? calibrationFloor : emaAmplitude
        let peakRef = max(calibrationPeakRef, floor + 0.0001)
        let effort = (emaAmplitude - floor) / max(0.0001, peakRef - floor)
        return clamp(effort)
    }

    private func band(for effort: Double) -> BreathBand {
        switch effort {
        case ..<0.33: .gentle
        case ..<0.67: .steady
        default: .strong
        }
    }

    private func resolveStableBand(rawBand: BreathBand, elapsedSec: Double) -> BreathBand {
        guard rawBand != stableBand else {
            pendingBand = nil
            pendingBandSince = 0
            return stableBand
        }

        if pendingBand != rawBand {
            pendingBand = rawBand
            pendingBandSince = elapsedSec
            return stableBand
        }

        guard elapsedSec - pendingBandSince >= hysteresisSec else {
            return stableBand
        }

        let previous = stableBand
        stableBand = rawBand
        pendingBand = nil
        pendingBandSince = 0
        events.onBandChanged?(previous, stableBand, elapsedSec, mode)
        return stableBand
    }

    private func accumulateSummary(phase: BreathPhase, effort: Double, stableBand: BreathBand, deltaSec: Double) {
        switch phase {
        case .inhale:
            inhaleDurationSec += deltaSec
            inhaleEffortIntegral += effort * deltaSec
        case .exhale:
            exhaleDurationSec += deltaSec
            exhaleEffortIntegral += effort * deltaSec
        }

        if stableBand == .steady {
            steadyRunSec += deltaSec
            steadyBandDurationSec += deltaSec
            if !steadyAchievementEmitted && steadyRunSec >= 3 {
                steadyAchievementEmitted = true
                events.onSteadyStreakAchieved?(steadyRunSec, mode)
            }
        } else {
            steadyRunSec = 0
        }
    }

    private func makeSummary() -> BreathIntensitySummary {
        BreathIntensitySummary(
            avgInhaleEffort: inhaleEffortIntegral / max(inhaleDurationSec, 0.0001),
            avgExhaleEffort: exhaleEffortIntegral / max(exhaleDurationSec, 0.0001),
            timeInSteadyBandSec: steadyBandDurationSec
        )
    }

    private func publishSnapshot(
        elapsedSec: Double,
        phase: BreathPhase? = nil,
        phaseProgress: Double? = nil,
        effort: Double? = nil,
        rawBand: BreathBand? = nil,
        stableBand: BreathBand? = nil
    ) {
        let phaseInfo = phase.map { ($0, phaseProgress ?? 0) } ?? self.phaseInfo(for: elapsedSec)
        let activeEffort = effort ?? computeEffort(elapsedSec: elapsedSec, phase: phaseInfo.0, phaseProgress: phaseInfo.1)
        let activeRawBand = rawBand ?? band(for: activeEffort)
        let activeStableBand = stableBand ?? self.stableBand

        let cycleCount = max(1, Int((config.totalSeconds / config.cycleSeconds).rounded()))
        let cycleIndex = min(cycleCount, Int(floor(elapsedSec / config.cycleSeconds)) + 1)

        onSnapshot?(
            BreathingSessionSnapshot(
                state: state,
                mode: mode,
                phase: phaseInfo.0,
                phaseProgress: phaseInfo.1,
                elapsedSec: elapsedSec,
                remainingSec: max(0, config.totalSeconds - elapsedSec),
                cycleIndex: cycleIndex,
                cycleCount: cycleCount,
                effort: activeEffort,
                rawBand: activeRawBand,
                stableBand: activeStableBand,
                steadyRunSec: steadyRunSec,
                isCalibrating: mode == .microphone && elapsedSec <= calibrationWindowSec
            )
        )
    }

    private func clamp(_ value: Double, min lower: Double = 0, max upper: Double = 1) -> Double {
        Swift.min(Swift.max(value, lower), upper)
    }
}
