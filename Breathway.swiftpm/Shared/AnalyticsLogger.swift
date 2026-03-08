import Foundation
import os

struct AnalyticsEventRecord: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let timestamp: Date
    let parameters: [String: String]
}

final class AnalyticsLogger {
    private enum EventName {
        static let levelRecommended = "level_recommended"
        static let breathingPlayStarted = "breathing_play_started"
        static let breathEffortBandChanged = "breath_effort_band_changed"
        static let steadyStreakAchieved = "breath_effort_steady_streak_achieved"
        static let missionStoppedForSafety = "mission_stopped_for_safety"
        static let breathingPlayCompleted = "breathing_play_completed"
    }

    private enum Storage {
        static let key = "breathway.analytics.events"
        static let maxEventCount = 200
    }

    private let userDefaults: UserDefaults
    private let logger = Logger(subsystem: "com.Wade.SSC.Breathway", category: "analytics")

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func trackLevelRecommended(
        recommendation: SessionRecommendation,
        adsScore: Int,
        selection: ReadinessSelectionState,
        context: ReadinessScoreContext
    ) {
        track(
            name: EventName.levelRecommended,
            parameters: [
                "recommended_level": recommendation.label.lowercased(),
                "ads_score": String(adsScore),
                "dyspnea": String(selection.breathlessness.rawValue),
                "fatigue": String(selection.fatigue.rawValue),
                "confidence": String(selection.confidence.rawValue),
                "last7_completion_rate": String(format: "%.2f", context.last7CompletionRate),
                "last_rpe_after": String(context.lastRPEAfter),
                "consecutive_safety_stops": String(context.consecutiveSafetyStops)
            ]
        )
    }

    func trackBreathingPlayStarted(mode: BreathCaptureMode, recommendation: SessionRecommendation) {
        track(
            name: EventName.breathingPlayStarted,
            parameters: [
                "mode": mode.rawValue,
                "recommended_level": recommendation.label.lowercased()
            ]
        )
    }

    func trackBreathEffortBandChanged(
        previousBand: BreathBand,
        newBand: BreathBand,
        elapsedSec: Double,
        mode: BreathCaptureMode
    ) {
        track(
            name: EventName.breathEffortBandChanged,
            parameters: [
                "previous_band": previousBand.rawValue,
                "new_band": newBand.rawValue,
                "elapsed_sec": format(elapsedSec),
                "mode": mode.rawValue
            ]
        )
    }

    func trackSteadyStreakAchieved(steadyRunSec: Double, elapsedSec: Double, mode: BreathCaptureMode) {
        track(
            name: EventName.steadyStreakAchieved,
            parameters: [
                "steady_run_sec": format(steadyRunSec),
                "elapsed_sec": format(elapsedSec),
                "mode": mode.rawValue
            ]
        )
    }

    func trackMissionStoppedForSafety(reason: String, elapsedSec: Double, mode: BreathCaptureMode) {
        track(
            name: EventName.missionStoppedForSafety,
            parameters: [
                "reason": reason,
                "elapsed_sec": format(elapsedSec),
                "mode": mode.rawValue
            ]
        )
    }

    func trackBreathingPlayCompleted(durationSec: Double, summary: BreathIntensitySummary, mode: BreathCaptureMode) {
        track(
            name: EventName.breathingPlayCompleted,
            parameters: [
                "duration_sec": format(durationSec),
                "avg_inhale_effort": format(summary.avgInhaleEffort),
                "avg_exhale_effort": format(summary.avgExhaleEffort),
                "time_in_steady_band_sec": format(summary.timeInSteadyBandSec),
                "mode": mode.rawValue
            ]
        )
    }

    func recentEvents(limit: Int = 50) -> [AnalyticsEventRecord] {
        let events = loadEvents()
        guard limit > 0 else { return [] }
        return Array(events.suffix(limit))
    }

    private func track(name: String, parameters: [String: String]) {
        var events = loadEvents()
        events.append(
            AnalyticsEventRecord(
                id: UUID(),
                name: name,
                timestamp: Date(),
                parameters: parameters
            )
        )

        if events.count > Storage.maxEventCount {
            events.removeFirst(events.count - Storage.maxEventCount)
        }

        saveEvents(events)
        logger.log("Tracked event: \(name, privacy: .public) \(parameters.description, privacy: .public)")
    }

    private func loadEvents() -> [AnalyticsEventRecord] {
        guard
            let data = userDefaults.data(forKey: Storage.key),
            let events = try? JSONDecoder().decode([AnalyticsEventRecord].self, from: data)
        else {
            return []
        }
        return events
    }

    private func saveEvents(_ events: [AnalyticsEventRecord]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        userDefaults.set(data, forKey: Storage.key)
    }

    private func format(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
}
