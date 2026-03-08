import Foundation

final class ReadinessViewModel: ObservableObject {
    @Published private(set) var selection: ReadinessSelectionState
    @Published private(set) var recommendation: SessionRecommendation = .standard
    @Published private(set) var adsScore: Int = 0
    @Published private(set) var guidanceText: String = ""
    @Published private(set) var guidanceTone: GuidanceTone = .supportive

    private let scoreContext: ReadinessScoreContext
    var onContinue: ((SessionRecommendation, ReadinessSelectionState, Int) -> Void)?
    var onRecommendationComputed: ((SessionRecommendation, Int, ReadinessSelectionState, ReadinessScoreContext) -> Void)?

    init(
        selection: ReadinessSelectionState = .default,
        scoreContext: ReadinessScoreContext = .default,
        onContinue: ((SessionRecommendation, ReadinessSelectionState, Int) -> Void)? = nil
    ) {
        self.selection = selection
        self.scoreContext = scoreContext
        self.onContinue = onContinue
        recomputeRecommendation()
    }

    func select(_ level: ReadinessLevel, in domain: ReadinessDomain) {
        guard selection[domain] != level else { return }
        selection[domain] = level
        recomputeRecommendation()
    }

    func adjust(_ direction: ReadinessAdjustDirection, in domain: ReadinessDomain) {
        let current = selection[domain]
        let updated: ReadinessLevel = {
            switch direction {
            case .increment: current.next
            case .decrement: current.previous
            }
        }()

        guard updated != current else { return }
        selection[domain] = updated
        recomputeRecommendation()
    }

    func continueTapped() {
        onContinue?(recommendation, selection, adsScore)
    }

    private func recomputeRecommendation() {
        adsScore = computeADS(
            dyspnea: selection.breathlessness.rawValue,
            fatigue: selection.fatigue.rawValue,
            last7CompletionRate: scoreContext.last7CompletionRate,
            lastRPEAfter: scoreContext.lastRPEAfter
        )
        let computedRecommendation = computeRecommendation(
            dyspnea: selection.breathlessness,
            ads: adsScore,
            consecutiveSafetyStops: scoreContext.consecutiveSafetyStops
        )

        if selection.hasSevere {
            recommendation = .light
            guidanceTone = .safety
            guidanceText = "Severe symptoms selected. Light session is safer today."
        } else {
            recommendation = computedRecommendation
            guidanceTone = .supportive
            switch recommendation {
            case .light:
                guidanceText = "A light session is recommended to keep today comfortable."
            case .standard:
                guidanceText = "You are ready for today's standard session."
            }
        }

        onRecommendationComputed?(recommendation, adsScore, selection, scoreContext)
    }

    // R-04 / R-02 / R-03: ADS formula and clamp
    private func computeADS(
        dyspnea: Int,
        fatigue: Int,
        last7CompletionRate: Double,
        lastRPEAfter: Int
    ) -> Int {
        let rpePenalty = max(0, lastRPEAfter - 5) * 6
        let readiness = 100 - (dyspnea * 18 + fatigue * 14 + rpePenalty)
        let consistencyBonus = Int((last7CompletionRate * 20).rounded())
        return min(max(readiness + consistencyBonus, 0), 100)
    }

    // R-05 / R-01 / R-06: Recommendation priority order
    private func computeRecommendation(
        dyspnea: ReadinessLevel,
        ads: Int,
        consecutiveSafetyStops: Int
    ) -> SessionRecommendation {
        if consecutiveSafetyStops >= 2 {
            return .light
        }
        if dyspnea == .severe {
            return .light
        }
        if ads < 45 {
            return .light
        }
        return .standard
    }
}

enum ReadinessAdjustDirection {
    case increment
    case decrement
}
