import SwiftUI

struct BreathingPlayView: View {
    @StateObject private var viewModel: BreathingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isQuickReminderPresented = false
    @State private var isRecoveryGuidePresented = false
    @State private var isStopConfirmPresented = false
    @State private var autoPausedByReminder = false
    let onSkipToMoveGuide: () -> Void

    init(viewModel: BreathingViewModel, onSkipToMoveGuide: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSkipToMoveGuide = onSkipToMoveGuide
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                BreathingPlayBackgroundView(
                    phase: viewModel.snapshot.phase,
                    phaseProgress: viewModel.snapshot.phaseProgress,
                    reduceMotion: reduceMotion
                )

                BreathingPlayTemplateView(
                    snapshot: viewModel.snapshot,
                    pauseButtonLabel: viewModel.pauseButtonLabel,
                    pauseButtonIcon: viewModel.pauseButtonIcon,
                    waveTitle: viewModel.waveTitle,
                    waveMetricText: viewModel.waveMetricText,
                    waveHint: viewModel.waveHint,
                    timerText: viewModel.timerText,
                    reduceMotion: reduceMotion,
                    onPauseResume: viewModel.pauseResumeTapped,
                    onStop: openStopConfirm,
                    onUnwell: { openRecoveryGuide(reason: "need_rest_button") }
                )
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                toolbarCapsuleButton(label: "Skip", action: skipToSitToStandGuide)
                    .accessibilityLabel("Skip breathing and open sit-to-stand guide")
            }
            ToolbarItem(placement: .topBarTrailing) {
                toolbarCapsuleButton(label: "Guide", action: openQuickReminder)
                    .accessibilityLabel("Open quick breathing reminder")
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if isQuickReminderPresented {
                BreathingQuickReminderSheetView(
                    profile: viewModel.recommendation.intensityProfile,
                    onDismiss: closeQuickReminderAndResumeIfNeeded
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            if isRecoveryGuidePresented {
                RecoveryGuideSheetView(
                    context: .breathing,
                    onRestartSession: closeRecoveryGuideAndResume,
                    onBackToHome: closeRecoveryGuideAndExitToHome,
                    onDismiss: closeRecoveryGuideAndResume
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .alert("Exit breathing session?", isPresented: $isStopConfirmPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Exit to Home", role: .destructive) {
                viewModel.requestStopToHome()
            }
        } message: {
            Text("Your current breathing mission will stop and return to Home.")
        }
        .animation(.easeInOut(duration: 0.24), value: isQuickReminderPresented)
        .animation(.easeInOut(duration: 0.24), value: isRecoveryGuidePresented)
        .onAppear {
            viewModel.startIfNeeded()
        }
        .onDisappear {
            viewModel.viewDidDisappear()
        }
        .sensoryFeedback(.selection, trigger: viewModel.phaseHapticTrigger)
        .sensoryFeedback(.success, trigger: viewModel.steadyHapticTrigger)
        .sensoryFeedback(.warning, trigger: viewModel.safetyHapticTrigger)
        .accessibilityElement(children: .contain)
    }

    private func openQuickReminder() {
        guard !isQuickReminderPresented, !isRecoveryGuidePresented else { return }
        autoPausedByReminder = viewModel.pauseForQuickReminderIfNeeded()
        isQuickReminderPresented = true
    }

    private func skipToSitToStandGuide() {
        guard !isQuickReminderPresented, !isRecoveryGuidePresented else { return }
        let didSkip = viewModel.skipToMoveGuideTapped()
        guard didSkip else { return }
        onSkipToMoveGuide()
    }

    private func closeQuickReminderAndResumeIfNeeded() {
        guard isQuickReminderPresented else { return }
        isQuickReminderPresented = false
        viewModel.resumeAfterQuickReminderIfNeeded(autoPausedByReminder)
        autoPausedByReminder = false
    }

    private func openStopConfirm() {
        guard !isQuickReminderPresented, !isRecoveryGuidePresented else { return }
        isStopConfirmPresented = true
    }

    private func openRecoveryGuide(reason: String) {
        guard !isRecoveryGuidePresented else { return }

        if isQuickReminderPresented {
            isQuickReminderPresented = false
            autoPausedByReminder = false
        }

        let didOpen = viewModel.openRecoveryGuideForSafety(reason: reason)
        guard didOpen else { return }
        isRecoveryGuidePresented = true
    }

    private func closeRecoveryGuideAndResume() {
        guard isRecoveryGuidePresented else { return }
        isRecoveryGuidePresented = false
        viewModel.resumeAfterRecoveryGuide()
    }

    private func closeRecoveryGuideAndExitToHome() {
        guard isRecoveryGuidePresented else { return }
        isRecoveryGuidePresented = false
        viewModel.exitToHomeFromRecoveryGuide()
    }

    @ViewBuilder
    private func toolbarCapsuleButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .fixedSize(horizontal: true, vertical: false)
                .background(
                    Capsule(style: .continuous)
                        .fill(BW2Tokens.ColorPalette.surfaceOnImageMedium)
                )
        }
        .buttonStyle(.plain)
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderOnImage, lineWidth: 1)
        )
    }
}

private struct BreathingPlayTemplateView: View {
    let snapshot: BreathingSessionSnapshot
    let pauseButtonLabel: String
    let pauseButtonIcon: String
    let waveTitle: String
    let waveMetricText: String
    let waveHint: String
    let timerText: String
    let reduceMotion: Bool
    let onPauseResume: () -> Void
    let onStop: () -> Void
    let onUnwell: () -> Void

    private enum Layout {
        static let paneHorizontalInset: CGFloat = 20
        static let paneVerticalInset: CGFloat = 54
    }

    private var palette: BreathingPhasePalette {
        BreathingPhasePalette(phase: snapshot.phase)
    }

    var body: some View {
        GeometryReader { proxy in
            let paneHorizontalInset = max(Layout.paneHorizontalInset, proxy.size.width * 0.017)
            let paneVerticalInset = max(Layout.paneVerticalInset, proxy.size.height * 0.086)
            let paneWidth = max(0, proxy.size.width - (paneHorizontalInset * 2))
            let paneHeight = max(0, proxy.size.height - (paneVerticalInset * 2))
            let contentHorizontalInset = max(20, paneWidth * 0.04)

            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    BreathingSessionPills()
                        .padding(.top, max(10, paneHeight * 0.008))

                    if snapshot.mode == .rhythmOnly {
                        RhythmOnlyBadge()
                            .padding(.top, 10)
                    } else if snapshot.isCalibrating {
                        CalibrationBadge()
                            .padding(.top, 10)
                    }

                    Spacer(minLength: max(24, paneHeight * 0.06))

                    Text(snapshot.phase.title)
                        .font(.system(size: 92, weight: .bold))
                        .foregroundStyle(palette.phaseTitle)
                        .shadow(color: Color.black.opacity(0.34), radius: 10, y: 4)
                        .minimumScaleFactor(0.74)
                        .animation(.easeInOut(duration: reduceMotion ? 0.18 : 0.45), value: snapshot.phase)

                    Text(snapshot.phase.guidance)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(palette.phaseBody)
                        .lineSpacing(2)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.28), radius: 6, y: 2)
                        .padding(.top, 8)

                    Spacer(minLength: max(6, paneHeight * 0.02))

                    BreathingWaveCard(
                        snapshot: snapshot,
                        title: waveTitle,
                        metricText: waveMetricText,
                        hintText: waveHint,
                        reduceMotion: reduceMotion
                    )
                    .frame(maxWidth: min(356, paneWidth * 0.42))
                    .padding(.top, max(4, paneHeight * 0.008))

                    Spacer(minLength: max(8, paneHeight * 0.02))

                    Text("Breath cycle \(snapshot.cycleIndex) / \(snapshot.cycleCount)")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    BreathingSafetyBar(
                        pauseButtonLabel: pauseButtonLabel,
                        pauseButtonIcon: pauseButtonIcon,
                        onPauseResume: onPauseResume,
                        onStop: onStop,
                        onUnwell: onUnwell
                    )
                    .frame(maxWidth: min(390, paneWidth * 0.42))
                    .padding(.top, max(10, paneHeight * 0.014))

                    Text("Longer exhale turns on the next beacon.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(BW2Tokens.ColorPalette.textOnImageSecondary)
                        .minimumScaleFactor(0.8)
                        .padding(.top, 8)
                        .padding(.bottom, max(4, paneHeight * 0.004))
                }
                .padding(.horizontal, paneHorizontalInset + contentHorizontalInset)
                .padding(.top, paneVerticalInset + 4 + BW2Tokens.Size.globalTopContentInset)
                .padding(.bottom, paneVerticalInset + 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack {
                    HStack {
                        Spacer()
                        BreathingTimerCard(
                            timerText: timerText,
                            remainingSeconds: Int(snapshot.remainingSec.rounded(.up)),
                            progressRatio: progressRatio,
                            valueColor: palette.timerText,
                            fillColor: timerFillColor,
                            topColor: timerCardTopColor,
                            bottomColor: timerCardBottomColor,
                            strokeColor: timerCardStrokeColor
                        )
                        .frame(width: min(375, max(312, paneWidth * 0.34)), height: 142)
                    }
                    .padding(.trailing, paneHorizontalInset + max(8, paneWidth * 0.018))
                    .padding(.top, paneVerticalInset + max(8, paneHeight * 0.008) + BW2Tokens.Size.globalTopContentInset)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var progressRatio: Double {
        let total = snapshot.elapsedSec + snapshot.remainingSec
        guard total > 0 else { return 0 }
        return min(1, max(0, snapshot.elapsedSec / total))
    }

    private var timerCardTopColor: Color {
        switch snapshot.phase {
        case .inhale:
            Color(hex: "DFECFA", alpha: 0.63)
        case .exhale:
            Color(hex: "F8E7CC", alpha: 0.58)
        }
    }

    private var timerCardBottomColor: Color {
        switch snapshot.phase {
        case .inhale:
            Color(hex: "5A6E88", alpha: 0.66)
        case .exhale:
            Color(hex: "845956", alpha: 0.63)
        }
    }

    private var timerCardStrokeColor: Color {
        switch snapshot.phase {
        case .inhale:
            Color(hex: "E3EEFF", alpha: 0.67)
        case .exhale:
            Color(hex: "FBE7C7", alpha: 0.67)
        }
    }

    private var timerFillColor: Color {
        switch snapshot.phase {
        case .inhale:
            Color(hex: "BFDFFF")
        case .exhale:
            Color(hex: "FFD49B")
        }
    }
}

private struct BreathingSessionPills: View {
    var body: some View {
        HStack(spacing: 12) {
            BreathingSessionPill(
                label: "Breathe",
                symbol: "●",
                symbolColor: Color(hex: "66E8D9"),
                textColor: Color(hex: "F7EEDF"),
                width: 116,
                textWeight: .semibold,
                topColor: Color(hex: "D1BAA9", alpha: 0.40),
                bottomColor: Color(hex: "7F7067", alpha: 0.52),
                strokeColor: Color(hex: "F6EEE0", alpha: 0.48)
            )

            BreathingSessionPill(
                label: "Move",
                symbol: "○",
                symbolColor: BW2Tokens.ColorPalette.textOnImageMuted,
                textColor: Color(hex: "E8DFD2"),
                width: 98,
                textWeight: .medium,
                topColor: Color(hex: "D1BAA9", alpha: 0.40),
                bottomColor: Color(hex: "7F7067", alpha: 0.52),
                strokeColor: Color(hex: "F6EEE0", alpha: 0.48)
            )

            BreathingSessionPill(
                label: "Done",
                symbol: "○",
                symbolColor: BW2Tokens.ColorPalette.textOnImageMuted,
                textColor: Color(hex: "E8DFD2"),
                width: 98,
                textWeight: .medium,
                topColor: Color(hex: "D1BAA9", alpha: 0.40),
                bottomColor: Color(hex: "7F7067", alpha: 0.52),
                strokeColor: Color(hex: "F6EEE0", alpha: 0.48)
            )
        }
        .frame(maxWidth: 370)
    }
}

private struct BreathingSessionPill: View {
    let label: String
    let symbol: String
    let symbolColor: Color
    let textColor: Color
    let width: CGFloat
    let textWeight: Font.Weight
    let topColor: Color
    let bottomColor: Color
    let strokeColor: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(symbolColor)
                .accessibilityHidden(true)

            Text(label)
                .font(.system(size: 16, weight: textWeight))
                .foregroundStyle(textColor)
        }
        .frame(width: width, height: 40)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [topColor, bottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        )
    }
}

private struct BreathingWaveCard: View {
    let snapshot: BreathingSessionSnapshot
    let title: String
    let metricText: String
    let hintText: String
    let reduceMotion: Bool

    private var palette: BreathingPhasePalette {
        BreathingPhasePalette(phase: snapshot.phase)
    }

    private let barPattern: [Double] = [0.24, 0.38, 0.56, 0.78, 1.0, 0.78, 0.56, 0.38, 0.24]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { context in
            let pulse: Double = reduceMotion
                ? 0.55
                : (0.5 + 0.5 * sin(context.date.timeIntervalSinceReferenceDate * 3.2))
            let intensity = min(1, max(0, snapshot.effort * 0.82 + pulse * 0.22))
            let activeLevelIndex: Int = {
                switch snapshot.stableBand {
                case .gentle: 1
                case .steady: 2
                case .strong: 4
                }
            }()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.waveTitle)
                    Spacer()
                    Text(metricText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.waveValue)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                ZStack {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [palette.waveGlowStart, Color.clear],
                                center: .center,
                                startRadius: 8,
                                endRadius: 64
                            )
                        )
                        .frame(width: 102, height: 62)

                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(barPattern.enumerated()), id: \.offset) { index, base in
                            let targetHeight = 12 + (40 * base * intensity)
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(index == 4 ? palette.barCenter : palette.barRegular.opacity(0.65 + (base * 0.35)))
                                .frame(width: 14, height: targetHeight)
                                .shadow(
                                    color: index == 4 ? palette.barCenterGlow : .clear,
                                    radius: index == 4 ? 10 : 0
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

                HStack(spacing: 10) {
                    ForEach(0 ..< 5, id: \.self) { index in
                        Circle()
                            .fill(index <= activeLevelIndex ? palette.levelDotActive : palette.levelDotInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)

                Text(hintText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.waveHint)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [palette.waveBackgroundTop, palette.waveBackgroundBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(palette.waveStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 22, y: 8)
            .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.45), value: snapshot.phase)
        }
        .frame(height: 149)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breath intensity wave")
        .accessibilityValue("\(snapshot.stableBand.title), effort \(Int(snapshot.effort * 100)) percent")
    }
}

private struct BreathingSafetyBar: View {
    let pauseButtonLabel: String
    let pauseButtonIcon: String
    let onPauseResume: () -> Void
    let onStop: () -> Void
    let onUnwell: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            BreathingControlButton(
                iconText: pauseButtonIcon,
                label: pauseButtonLabel,
                width: 118,
                iconColor: Color(hex: "F8F1E8"),
                gradientTop: BW2Tokens.ColorPalette.surfaceOnImageStrong,
                gradientBottom: BW2Tokens.ColorPalette.surfaceOnImageMedium,
                stroke: BW2Tokens.ColorPalette.borderOnImage,
                accessibilityLabel: pauseButtonLabel,
                onTap: onPauseResume
            )

            BreathingControlButton(
                iconText: "■",
                label: "End",
                width: 118,
                iconColor: Color(hex: "F8F1E8"),
                gradientTop: BW2Tokens.ColorPalette.surfaceOnImageStrong,
                gradientBottom: BW2Tokens.ColorPalette.surfaceOnImageMedium,
                stroke: BW2Tokens.ColorPalette.borderOnImage,
                accessibilityLabel: "End breathing mission",
                onTap: onStop
            )

            BreathingControlButton(
                systemIcon: "exclamationmark.triangle.fill",
                label: "Need Rest",
                width: 130,
                iconColor: Color(hex: "FFE3B8"),
                gradientTop: BW2Tokens.ColorPalette.surfaceOnImageStrong,
                gradientBottom: BW2Tokens.ColorPalette.surfaceOnImageMedium,
                stroke: Color(hex: "FFE2B2", alpha: 0.56),
                accessibilityLabel: "Need rest",
                onTap: onUnwell
            )
        }
        .padding(.top, 2)
    }
}

private struct BreathingControlButton: View {
    var iconText: String?
    var systemIcon: String?
    let label: String
    let width: CGFloat
    let iconColor: Color
    let gradientTop: Color
    let gradientBottom: Color
    let stroke: Color
    var textColor: Color = BW2Tokens.ColorPalette.textOnImageSecondary
    var labelFontSize: CGFloat = 13
    var labelFontWeight: Font.Weight = .medium
    let accessibilityLabel: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 1) {
                if let iconText {
                    Text(iconText)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(iconColor)
                        .accessibilityHidden(true)
                } else if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .accessibilityHidden(true)
                }

                Text(label)
                    .font(.system(size: labelFontSize, weight: labelFontWeight))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(width: width, height: 86)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [gradientTop, gradientBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            )
            .bwAdaptiveGlass(
                cornerRadius: 22,
                tint: Color.white.opacity(0.02),
                interactive: true,
                strokeColor: Color.clear,
                shadowColor: Color.black.opacity(0.2),
                shadowRadius: 16,
                shadowY: 8
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct BreathingTimerProgressBar: View {
    let progressRatio: Double
    let fillColor: Color
    let trackColor: Color

    private var clampedProgress: Double {
        min(1, max(0, progressRatio))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .continuous)
                .fill(trackColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Capsule(style: .continuous)
                .fill(fillColor.opacity(0.95))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(x: clampedProgress, y: 1, anchor: .leading)
                .animation(.linear(duration: 0.2), value: clampedProgress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing session progress")
        .accessibilityValue("\(Int((clampedProgress * 100).rounded())) percent")
    }
}

private struct BreathingTimerCard: View {
    let timerText: String
    let remainingSeconds: Int
    let progressRatio: Double
    let valueColor: Color
    let fillColor: Color
    let topColor: Color
    let bottomColor: Color
    let strokeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Text("TIME PROGRESS")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textOnImageSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 8)

                Text("\(max(0, remainingSeconds))s left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textOnImageSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text(timerText)
                .font(.system(size: 54, weight: .bold))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            BreathingTimerProgressBar(
                progressRatio: progressRatio,
                fillColor: fillColor,
                trackColor: Color.white.opacity(0.27)
            )
            .frame(height: 10)
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [topColor, bottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
    }
}

private struct BreathingPlayBackgroundView: View {
    let phase: BreathPhase
    let phaseProgress: Double
    let reduceMotion: Bool

    private var palette: BreathingPhasePalette {
        BreathingPhasePalette(phase: phase)
    }

    var body: some View {
        ZStack {
            Image("breathing_inhale_bg")
                .resizable()
                .scaledToFill()
                .opacity(phase == .inhale ? 1 : 0)
                .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.6), value: phase)
                .ignoresSafeArea()

            Image("breathing_exhale_bg")
                .resizable()
                .scaledToFill()
                .opacity(phase == .exhale ? 1 : 0)
                .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.6), value: phase)
                .ignoresSafeArea()

            LinearGradient(
                colors: [palette.overlayTop, palette.overlayBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.6), value: phase)
        }
    }
}

private struct RhythmOnlyBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "1F778F"))
                .accessibilityHidden(true)
            Text("Rhythm-only mode")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.84))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .bwAdaptiveGlass(
            cornerRadius: BW2Tokens.Radius.pill,
            tint: Color.white.opacity(0.04),
            strokeColor: Color.clear,
            shadowColor: .clear,
            shadowRadius: 0,
            shadowY: 0
        )
    }
}

private struct CalibrationBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(0.65)
                .tint(Color(hex: "1C7F89"))
                .accessibilityHidden(true)
            Text("Calibrating breath input…")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.84))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
    }
}

private struct BreathingPhasePalette {
    let phase: BreathPhase

    var overlayTop: Color {
        switch phase {
        case .inhale: BW2Tokens.ColorPalette.overlayCoolTop
        case .exhale: BW2Tokens.ColorPalette.overlayWarmTop
        }
    }

    var overlayBottom: Color {
        switch phase {
        case .inhale: BW2Tokens.ColorPalette.overlayCoolBottom
        case .exhale: BW2Tokens.ColorPalette.overlayWarmBottom
        }
    }

    var glowColor: Color {
        switch phase {
        case .inhale: Color(hex: "9DC7F2")
        case .exhale: Color(hex: "F8D19A")
        }
    }

    var secondaryGlow: Color {
        switch phase {
        case .inhale: Color(hex: "D9ECFF")
        case .exhale: Color(hex: "FFE4BD")
        }
    }

    var phaseTitle: Color {
        switch phase {
        case .inhale: Color(hex: "E9F0F7")
        case .exhale: Color(hex: "FBF3E7")
        }
    }

    var phaseBody: Color {
        switch phase {
        case .inhale: Color(hex: "D7E2EE")
        case .exhale: BW2Tokens.ColorPalette.textOnImageSecondary
        }
    }

    var timerText: Color {
        BW2Tokens.ColorPalette.textOnImagePrimary
    }

    var waveTitle: Color {
        switch phase {
        case .inhale: Color(hex: "DFEAF6")
        case .exhale: Color(hex: "F8F0E2")
        }
    }

    var waveValue: Color {
        switch phase {
        case .inhale: Color(hex: "CFE0F4")
        case .exhale: Color(hex: "F7E6C4")
        }
    }

    var waveGlowStart: Color {
        switch phase {
        case .inhale: Color(hex: "A7C5EE", alpha: 0.43)
        case .exhale: Color(hex: "F6CB7A", alpha: 0.48)
        }
    }

    var waveBackgroundTop: Color {
        switch phase {
        case .inhale: Color(hex: "E9F1FA", alpha: 0.26)
        case .exhale: Color(hex: "FAF2E7", alpha: 0.50)
        }
    }

    var waveBackgroundBottom: Color {
        switch phase {
        case .inhale: Color(hex: "6E8093", alpha: 0.29)
        case .exhale: Color(hex: "D9C1A2", alpha: 0.48)
        }
    }

    var waveStroke: Color {
        switch phase {
        case .inhale: Color(hex: "D5E2F2", alpha: 0.43)
        case .exhale: Color(hex: "F8EFDFA8")
        }
    }

    var barRegular: Color {
        switch phase {
        case .inhale: Color(hex: "BCD1EB")
        case .exhale: Color(hex: "F7E3B3")
        }
    }

    var barCenter: Color {
        switch phase {
        case .inhale: Color(hex: "EAF3FF")
        case .exhale: Color(hex: "FFECC5")
        }
    }

    var barCenterGlow: Color {
        switch phase {
        case .inhale: Color(hex: "BFD8F6", alpha: 0.52)
        case .exhale: Color(hex: "F7CE7A", alpha: 0.50)
        }
    }

    var levelDotActive: Color {
        switch phase {
        case .inhale: Color(hex: "D8E7FC")
        case .exhale: Color(hex: "FFE7C8")
        }
    }

    var levelDotInactive: Color {
        switch phase {
        case .inhale: Color(hex: "B7C7DC", alpha: 0.35)
        case .exhale: Color(hex: "F5DBAA", alpha: 0.42)
        }
    }

    var waveHint: Color {
        switch phase {
        case .inhale: Color(hex: "C7D7EA")
        case .exhale: Color(hex: "F1E8DA")
        }
    }
}

#Preview("Breathing Inhale") {
    NavigationStack {
        BreathingPlayView(
            viewModel: BreathingViewModel(recommendation: .standard)
        )
    }
}
