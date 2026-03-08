import SwiftUI

struct AppRootView: View {
    @AppStorage(AppStorageKeys.showBeforeBreathingGuide) private var showBeforeBreathingGuide = true
    @AppStorage(AppStorageKeys.showBeforeSitToStandGuide) private var showBeforeSitToStandGuide = true
    @AppStorage(AppStorageKeys.showOnboardingAtLaunch) private var showOnboardingAtLaunch = true
    @AppStorage(AppStorageKeys.hasSeenOnboarding) private var hasSeenOnboarding = false
    @AppStorage(AppStorageKeys.backgroundMusicEnabled) private var isBackgroundMusicEnabled = true
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var navigationManager = NavigationManager()
    @State private var selectedRecommendation: SessionRecommendation = .standard
    @State private var latestBreathSummary: BreathIntensitySummary?
    @State private var latestMoveSummary: MoveSessionSummary?
    @State private var isOnboardingPresented = false
    @State private var didCheckInitialOnboarding = false
    private let analyticsLogger = AnalyticsLogger()
    private let progressStore = ProgressStore()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            HomeView(
                viewModel: homeViewModel,
                onStart: { route in
                    navigationManager.push(route)
                },
                onOpenOnboarding: {
                    isOnboardingPresented = true
                },
                onOpenWeeklyProgress: {
                    navigationManager.push(.progressPlaceholder)
                },
                isBackgroundMusicEnabled: isBackgroundMusicEnabled,
                onToggleBackgroundMusic: {
                    isBackgroundMusicEnabled.toggle()
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .readiness:
                    ReadinessCheckView(viewModel: makeReadinessViewModel())
                case .breathGuideFirstEntry:
                    BreathGuideFirstEntryView(
                        showGuideBeforeMission: $showBeforeBreathingGuide,
                        recommendation: selectedRecommendation,
                        onStartMission: {
                            navigationManager.push(.breathingPlay)
                        }
                    )
                case .breathingPlay:
                    BreathingPlayView(
                        viewModel: makeBreathingViewModel(),
                        onSkipToMoveGuide: {
                            navigationManager.push(.rehabGuideSitToStand)
                        }
                    )
                case .rehabGuideSitToStand:
                    RehabGuideSitToStandView(
                        showGuideBeforeMission: $showBeforeSitToStandGuide,
                        recommendation: selectedRecommendation,
                        onStartMission: {
                            navigationManager.push(.movePlaySitToStand)
                        }
                    )
                case .movePlaySitToStand:
                    MovePlaySitToStandView(viewModel: makeMovePlayViewModel())
                case .dailyMissionResult:
                    DailyMissionResultView(
                        breathSummary: latestBreathSummary,
                        moveSummary: latestMoveSummary,
                        onBackToHome: {
                            navigationManager.popToRoot()
                        },
                        onViewProgress: {
                            navigationManager.push(.progressPlaceholder)
                        }
                    )
                case .progressPlaceholder:
                    ProgressPlaceholderView(
                        viewModel: makeProgressViewModel(),
                        onBackToResult: {
                            navigationManager.pop()
                        },
                        onBackToHome: {
                            navigationManager.popToRoot()
                        }
                    )
                }
            }
        }
        .onAppear {
            presentOnboardingIfNeeded()
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingView(
                onFinish: { dontShowAgain in
                    hasSeenOnboarding = true
                    showOnboardingAtLaunch = !dontShowAgain
                    isOnboardingPresented = false
                },
                onClose: {
                    isOnboardingPresented = false
                }
            )
            .interactiveDismissDisabled()
        }
    }

    private func makeReadinessViewModel() -> ReadinessViewModel {
        let viewModel = ReadinessViewModel(
            selection: .default,
            scoreContext: .init(
                last7CompletionRate: 0.60,
                lastRPEAfter: 5,
                consecutiveSafetyStops: 0
            ),
            onContinue: { recommendation, _, _ in
                selectedRecommendation = recommendation
                let route: AppRoute = shouldShowBreathingGuide()
                    ? .breathGuideFirstEntry
                    : .breathingPlay
                navigationManager.push(route)
            }
        )

        viewModel.onRecommendationComputed = { recommendation, adsScore, selection, context in
            analyticsLogger.trackLevelRecommended(
                recommendation: recommendation,
                adsScore: adsScore,
                selection: selection,
                context: context
            )
        }

        return viewModel
    }

    private func makeBreathingViewModel() -> BreathingViewModel {
        let intensityProfile = selectedRecommendation.intensityProfile
        let sessionRecommendation = selectedRecommendation
        let viewModel = BreathingViewModel(
            recommendation: sessionRecommendation,
            engine: BreathingSessionEngine(config: intensityProfile.breathConfig),
            analyticsLogger: analyticsLogger
        )

        viewModel.onExitToHomeRequested = {
            navigationManager.popToRoot()
        }

        viewModel.onCompleted = { summary in
            progressStore.append(
                ProgressSessionEvent(
                    kind: .breathing,
                    outcome: .completed,
                    durationSec: intensityProfile.breathConfig.totalSeconds,
                    recommendationLabel: sessionRecommendation.label.lowercased()
                )
            )
            latestBreathSummary = summary
            navigationManager.push(.rehabGuideSitToStand)
        }

        viewModel.onSafetyStop = {
            progressStore.append(
                ProgressSessionEvent(
                    kind: .breathing,
                    outcome: .safetyStop,
                    recommendationLabel: sessionRecommendation.label.lowercased(),
                    reason: "breathing_safety_stop"
                )
            )
        }

        return viewModel
    }

    private func makeMovePlayViewModel() -> MovePlayViewModel {
        let intensityProfile = selectedRecommendation.intensityProfile
        let sessionRecommendation = selectedRecommendation
        let viewModel = MovePlayViewModel(
            recommendation: sessionRecommendation,
            config: intensityProfile.moveConfig
        )

        viewModel.onExitToHomeRequested = {
            navigationManager.popToRoot()
        }

        viewModel.onFinishMission = { summary in
            let outcome: ProgressSessionOutcome = summary.completionReason == .completedByTimer ? .completed : .endedEarly
            progressStore.append(
                ProgressSessionEvent(
                    kind: .move,
                    outcome: outcome,
                    durationSec: summary.durationSec,
                    recommendationLabel: sessionRecommendation.label.lowercased(),
                    reason: summary.completionReason == .endedEarly ? "move_ended_early" : nil
                )
            )
            latestMoveSummary = summary
            if summary.completionReason == .completedByTimer {
                homeViewModel.markMissionCompletedToday()
            }
            navigationManager.push(.dailyMissionResult)
        }

        viewModel.onSafetyStop = {
            progressStore.append(
                ProgressSessionEvent(
                    kind: .move,
                    outcome: .safetyStop,
                    recommendationLabel: sessionRecommendation.label.lowercased(),
                    reason: "move_safety_stop"
                )
            )
        }

        return viewModel
    }

    private func makeProgressViewModel() -> ProgressViewModel {
        ProgressViewModel(
            streakStore: HomeStreakStore(),
            progressStore: progressStore
        )
    }

    private func shouldShowBreathingGuide() -> Bool {
        guard UserDefaults.standard.object(forKey: AppStorageKeys.showBeforeBreathingGuide) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: AppStorageKeys.showBeforeBreathingGuide)
    }

    private func presentOnboardingIfNeeded() {
        guard !didCheckInitialOnboarding else { return }
        didCheckInitialOnboarding = true

        guard !hasSeenOnboarding || showOnboardingAtLaunch else { return }
        isOnboardingPresented = true
    }
}

#Preview {
    AppRootView()
}
