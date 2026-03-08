import SwiftUI

private enum MovePlayCanvas {
    static let width: CGFloat = 1194
    static let height: CGFloat = 834
}

private enum MovePlayScreenVariant {
    case inhaleActive
    case exhaleActive
    case resultCompleted
    case resultSkipped

    var phaseForBackground: MovePhase {
        switch self {
        case .inhaleActive: .inhaleSit
        case .exhaleActive, .resultSkipped: .exhaleStand
        case .resultCompleted: .inhaleSit
        }
    }

    var isResult: Bool {
        switch self {
        case .inhaleActive, .exhaleActive: false
        case .resultCompleted, .resultSkipped: true
        }
    }
}

private enum RouteVisualState {
    case inhaleActive
    case exhaleActive
    case sessionComplete
    case safetySkip
}

private struct RouteVisualSpec {
    let hint: String
    let routeCardTopColor: Color
    let routeCardBottomColor: Color
    let routeCardStrokeColor: Color
    let routeCardHintColor: Color
    let routeCardLineColor: Color
    let routeCardLineThickness: CGFloat
    let routeCardHintWidth: CGFloat
    let routeCardHintX: CGFloat
    let routeCardHintWeight: Font.Weight
    let routeCardShowStartLabel: Bool
    let routeCardStartLabelColor: Color
    let harborLaneStyle: MoveHarborLaneStyle
    let harborRouteLineColor: Color?
    let harborPulseColor: Color?
    let routeLabelText: String?
    let routeLabelX: CGFloat
    let routeLabelColor: Color
    let rightLabelText: String
    let homeLabelColor: Color
    let outerStartRetryText: String?
    let outerStartRetryColor: Color

    static func active(for variant: MovePlayScreenVariant, hint: String) -> RouteVisualSpec {
        let state: RouteVisualState = variant == .inhaleActive ? .inhaleActive : .exhaleActive
        return make(for: state, dynamicHint: hint)
    }

    static func result(for variant: MovePlayScreenVariant, hint: String) -> RouteVisualSpec {
        let state: RouteVisualState = variant == .resultSkipped ? .safetySkip : .sessionComplete
        return make(for: state, dynamicHint: hint)
    }

    private static func make(for state: RouteVisualState, dynamicHint: String) -> RouteVisualSpec {
        switch state {
        case .inhaleActive:
            return RouteVisualSpec(
                hint: dynamicHint,
                routeCardTopColor: Color(hex: "D9E9F6", alpha: 0.63),
                routeCardBottomColor: Color(hex: "4A6075", alpha: 0.56),
                routeCardStrokeColor: Color(hex: "DCEAF8", alpha: 0.67),
                routeCardHintColor: Color(hex: "EAF3FA"),
                routeCardLineColor: Color(hex: "F4DEAF", alpha: 0.72),
                routeCardLineThickness: 0,
                routeCardHintWidth: 520,
                routeCardHintX: 210,
                routeCardHintWeight: .medium,
                routeCardShowStartLabel: false,
                routeCardStartLabelColor: Color(hex: "F7EBDD"),
                harborLaneStyle: .activeInhale,
                harborRouteLineColor: Color(hex: "C7D9E8", alpha: 0.56),
                harborPulseColor: Color(hex: "D9ECFF"),
                routeLabelText: nil,
                routeLabelX: 0,
                routeLabelColor: Color(hex: "FFF2CE"),
                rightLabelText: "Finish",
                homeLabelColor: Color(hex: "F7EBDD"),
                outerStartRetryText: "Start",
                outerStartRetryColor: Color(hex: "F7EBDD")
            )
        case .exhaleActive:
            return RouteVisualSpec(
                hint: dynamicHint,
                routeCardTopColor: Color(hex: "F6D9B4", alpha: 0.62),
                routeCardBottomColor: Color(hex: "6E5251", alpha: 0.54),
                routeCardStrokeColor: Color(hex: "F8E2C5", alpha: 0.66),
                routeCardHintColor: Color(hex: "F8F0E4"),
                routeCardLineColor: Color(hex: "F4DEAF", alpha: 0.72),
                routeCardLineThickness: 0,
                routeCardHintWidth: 520,
                routeCardHintX: 210,
                routeCardHintWeight: .medium,
                routeCardShowStartLabel: true,
                routeCardStartLabelColor: Color(hex: "F7EBDD"),
                harborLaneStyle: .activeExhale,
                harborRouteLineColor: Color(hex: "E9D9B8", alpha: 0.54),
                harborPulseColor: Color(hex: "FFEBC7"),
                routeLabelText: nil,
                routeLabelX: 0,
                routeLabelColor: Color(hex: "FFF2CE"),
                rightLabelText: "Finish",
                homeLabelColor: Color(hex: "F7EBDD"),
                outerStartRetryText: nil,
                outerStartRetryColor: Color(hex: "F7EBDD")
            )
        case .sessionComplete:
            return RouteVisualSpec(
                hint: dynamicHint,
                routeCardTopColor: Color(hex: "D9E9F6", alpha: 0.63),
                routeCardBottomColor: Color(hex: "4A6075", alpha: 0.56),
                routeCardStrokeColor: Color(hex: "DCEAF8", alpha: 0.67),
                routeCardHintColor: Color(hex: "FFF2DA"),
                routeCardLineColor: Color(hex: "F8E4B5", alpha: 0.80),
                routeCardLineThickness: 4,
                routeCardHintWidth: 580,
                routeCardHintX: 180,
                routeCardHintWeight: .semibold,
                routeCardShowStartLabel: false,
                routeCardStartLabelColor: Color(hex: "F7EBDD"),
                harborLaneStyle: .result,
                harborRouteLineColor: nil,
                harborPulseColor: nil,
                routeLabelText: "HARBOR ARRIVED",
                routeLabelX: 544,
                routeLabelColor: Color(hex: "FFF2CE"),
                rightLabelText: "Home",
                homeLabelColor: Color(hex: "F8EEDC"),
                outerStartRetryText: "Start",
                outerStartRetryColor: Color(hex: "EDE4D2", alpha: 0.72)
            )
        case .safetySkip:
            return RouteVisualSpec(
                hint: dynamicHint,
                routeCardTopColor: Color(hex: "D9E9F6", alpha: 0.63),
                routeCardBottomColor: Color(hex: "4A6075", alpha: 0.56),
                routeCardStrokeColor: Color(hex: "DCEAF8", alpha: 0.67),
                routeCardHintColor: Color(hex: "FFF2DA"),
                routeCardLineColor: Color(hex: "F8E4B5", alpha: 0.80),
                routeCardLineThickness: 4,
                routeCardHintWidth: 620,
                routeCardHintX: 160,
                routeCardHintWeight: .semibold,
                routeCardShowStartLabel: false,
                routeCardStartLabelColor: Color(hex: "F7EBDD"),
                harborLaneStyle: .skipped,
                harborRouteLineColor: nil,
                harborPulseColor: nil,
                routeLabelText: "SKIPPED FOR SAFETY",
                routeLabelX: 496,
                routeLabelColor: Color(hex: "FFF2CE"),
                rightLabelText: "Home",
                homeLabelColor: Color(hex: "F8EEDC"),
                outerStartRetryText: "Retry",
                outerStartRetryColor: Color(hex: "EDE4D2", alpha: 0.72)
            )
        }
    }
}

struct MovePlaySitToStandView: View {
    @StateObject private var viewModel: MovePlayViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isQuickReminderPresented = false
    @State private var isRecoveryGuidePresented = false
    @State private var isStopConfirmPresented = false
    @State private var autoPausedByQuickReminder = false

    init(viewModel: MovePlayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { proxy in
            let variant = screenVariant
            let scale = min(
                proxy.size.width / MovePlayCanvas.width,
                proxy.size.height / MovePlayCanvas.height
            )

            ZStack {
                MovePlayPenBackground(
                    phase: variant.phaseForBackground,
                    isResult: variant.isResult,
                    reduceMotion: reduceMotion,
                    frameSize: proxy.size
                )

                ZStack(alignment: .topLeading) {
                    switch variant {
                    case .inhaleActive, .exhaleActive:
                        MovePlayActiveCanvas(
                            snapshot: viewModel.snapshot,
                            variant: variant,
                            pauseButtonLabel: viewModel.pauseButtonLabel,
                            pauseButtonIcon: viewModel.pauseButtonIcon,
                            repRhythmHintText: viewModel.repRhythmHintText,
                            repsValueText: viewModel.repsValueText,
                            repsLeftText: viewModel.repsLeftText,
                            goalHintText: viewModel.goalHintText,
                            onPauseResume: viewModel.pauseResumeTapped,
                            onEnd: openStopConfirm,
                            onNeedRest: openRecoveryGuide
                        )
                    case .resultCompleted, .resultSkipped:
                        MovePlayResultCanvas(
                            snapshot: viewModel.snapshot,
                            variant: variant,
                            activeRouteHint: viewModel.repRhythmHintText,
                            repsValueText: viewModel.repsValueText,
                            repsLeftText: viewModel.repsLeftText,
                            goalHintText: viewModel.goalHintText,
                            resultHeadline: viewModel.resultHeadline,
                            resultCueTitle: viewModel.resultCueTitle,
                            resultCueSubtitle: viewModel.resultCueSubtitle,
                            resultRouteHint: viewModel.resultRouteHint,
                            onRetryTomorrow: viewModel.finishTappedFromResult,
                            onFinish: viewModel.finishTappedFromResult
                        )
                    }
                }
                .frame(width: MovePlayCanvas.width, height: MovePlayCanvas.height, alignment: .topLeading)
                .scaleEffect(scale, anchor: .center)
                .offset(y: BW2Tokens.Size.globalTopContentInset)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            if !viewModel.isShowingResult {
                ToolbarItem(placement: .topBarTrailing) {
                    toolbarCapsuleButton(label: "Guide", action: openQuickReminder)
                        .accessibilityLabel("Open quick sit-to-stand reminder")
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Exit movement session?", isPresented: $isStopConfirmPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Exit to Home", role: .destructive) {
                viewModel.requestStopToHome()
            }
        } message: {
            Text("Your current sit-to-stand mission will stop and return to Home.")
        }
        .overlay {
            if isQuickReminderPresented {
                QuickSitToStandReminderSheetView(
                    profile: viewModel.recommendation.intensityProfile,
                    onDismiss: closeQuickReminderAndResumeIfNeeded
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            if isRecoveryGuidePresented {
                RecoveryGuideSheetView(
                    context: .moveSitToStand,
                    onRestartSession: closeRecoveryGuideAndResume,
                    onBackToHome: closeRecoveryGuideAndExitToHome,
                    onDismiss: closeRecoveryGuideAndResume
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
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
        .sensoryFeedback(.success, trigger: viewModel.completionHapticTrigger)
        .sensoryFeedback(.warning, trigger: viewModel.safetyHapticTrigger)
        .accessibilityElement(children: .contain)
    }

    private var screenVariant: MovePlayScreenVariant {
        if viewModel.isShowingResult {
            if viewModel.summary?.completionReason == .endedEarly {
                return .resultSkipped
            }
            return .resultCompleted
        }
        return viewModel.snapshot.phase == .inhaleSit ? .inhaleActive : .exhaleActive
    }

    private func openQuickReminder() {
        guard !viewModel.isShowingResult else { return }
        guard !isQuickReminderPresented, !isRecoveryGuidePresented else { return }
        autoPausedByQuickReminder = viewModel.pauseForQuickReminderIfNeeded()
        isQuickReminderPresented = true
    }

    private func closeQuickReminderAndResumeIfNeeded() {
        guard isQuickReminderPresented else { return }
        isQuickReminderPresented = false
        viewModel.resumeAfterQuickReminderIfNeeded(autoPausedByQuickReminder)
        autoPausedByQuickReminder = false
    }

    private func openRecoveryGuide() {
        guard !isRecoveryGuidePresented else { return }
        if isQuickReminderPresented {
            isQuickReminderPresented = false
            autoPausedByQuickReminder = false
        }
        let didOpen = viewModel.openRecoveryGuideFromNeedRest()
        guard didOpen else { return }
        isRecoveryGuidePresented = true
    }

    private func openStopConfirm() {
        guard !isQuickReminderPresented, !isRecoveryGuidePresented else { return }
        isStopConfirmPresented = true
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

private struct MovePlayActiveCanvas: View {
    let snapshot: MoveSessionSnapshot
    let variant: MovePlayScreenVariant
    let pauseButtonLabel: String
    let pauseButtonIcon: String
    let repRhythmHintText: String
    let repsValueText: String
    let repsLeftText: String
    let goalHintText: String
    let onPauseResume: () -> Void
    let onEnd: () -> Void
    let onNeedRest: () -> Void

    private var phase: MovePhase { snapshot.phase }
    private var isInhale: Bool { variant == .inhaleActive }
    private var routeVisualSpec: RouteVisualSpec {
        RouteVisualSpec.active(for: variant, hint: repRhythmHintText)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            MoveSessionPillRow(mode: .active)
                .frame(width: 370, height: 44)
                .penPosition(412, 16)

            Text("SIT-TO-STAND")
                .font(.system(size: 88, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                .shadow(color: Color.black.opacity(0.36), radius: 12, y: 4)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
                .frame(width: MovePlayCanvas.width, alignment: .center)
                .penPosition(0, 214)

            Text(phase.subtitle)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                .shadow(color: Color.black.opacity(0.28), radius: 8, y: 2)
                .frame(width: MovePlayCanvas.width, alignment: .center)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .penPosition(0, 336)

            MoveCueCard(
                title: phase.cueTitle,
                subtitle: phase.cueInstruction,
                topColor: isInhale ? Color(hex: "DDEBFA", alpha: 0.66) : Color(hex: "F3DDB6", alpha: 0.66),
                bottomColor: isInhale ? Color(hex: "3F5D7C", alpha: 0.54) : Color(hex: "6E4C4A", alpha: 0.52),
                strokeColor: isInhale ? Color(hex: "DFEEFF", alpha: 0.65) : Color(hex: "FFEED3", alpha: 0.60),
                titleColor: isInhale ? Color(hex: "F4F9FF") : Color(hex: "FFF7EA"),
                subtitleColor: isInhale ? Color(hex: "DEECFB") : Color(hex: "F8E8D0")
            )
            .frame(width: 420, height: 86)
            .penPosition(387, 417)

            MoveRouteCard(
                hint: routeVisualSpec.hint,
                topColor: routeVisualSpec.routeCardTopColor,
                bottomColor: routeVisualSpec.routeCardBottomColor,
                strokeColor: routeVisualSpec.routeCardStrokeColor,
                hintColor: routeVisualSpec.routeCardHintColor,
                lineColor: routeVisualSpec.routeCardLineColor,
                lineThickness: routeVisualSpec.routeCardLineThickness,
                hintWidth: routeVisualSpec.routeCardHintWidth,
                hintX: routeVisualSpec.routeCardHintX,
                hintWeight: routeVisualSpec.routeCardHintWeight,
                showStartLabel: routeVisualSpec.routeCardShowStartLabel,
                startLabelColor: routeVisualSpec.routeCardStartLabelColor
            )
            .frame(width: 940, height: 128)
            .penPosition(132, 560)

            MoveHarborLane(
                litCount: snapshot.beaconLitCount,
                progressRatio: snapshot.timeProgressRatio,
                style: routeVisualSpec.harborLaneStyle,
                routeLineColorOverride: routeVisualSpec.harborRouteLineColor,
                pulseColorOverride: routeVisualSpec.harborPulseColor
            )
            .frame(width: 490, height: 58)
            .penPosition(352, 576)

            Text(routeVisualSpec.rightLabelText)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(routeVisualSpec.homeLabelColor)
                .penPosition(959, 594)

            if let startRetryText = routeVisualSpec.outerStartRetryText {
                Text(startRetryText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(routeVisualSpec.outerStartRetryColor)
                    .penPosition(219, 594)
            }

            MoveActiveControlBar(
                pauseButtonLabel: pauseButtonLabel,
                pauseButtonIcon: pauseButtonIcon,
                onPauseResume: onPauseResume,
                onEnd: onEnd,
                onNeedRest: onNeedRest
            )
            .frame(width: 390, height: 96)
            .penPosition(402, 708)

            Text("Need Rest if dizzy or breathless.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "EAF4FF"))
                .minimumScaleFactor(0.82)
                .lineLimit(1)
                .padding(.top, 6)
                .frame(width: MovePlayCanvas.width, alignment: .center)
                .penPosition(0, 796)

            MoveRepsCard(
                title: "REPS PROGRESS",
                valueText: repsValueText,
                rightHint: goalHintText,
                leftHint: repsLeftText,
                progressRatio: snapshot.progressRatio,
                valueColor: isInhale ? Color(hex: "F3F8FF") : Color(hex: "FFF3DE"),
                fillColor: isInhale ? Color(hex: "BFDFFF") : Color(hex: "FFD49B"),
                topColor: isInhale ? Color(hex: "DFECFA", alpha: 0.63) : Color(hex: "F8E7CC", alpha: 0.58),
                bottomColor: isInhale ? Color(hex: "5A6E88", alpha: 0.66) : Color(hex: "845956", alpha: 0.63),
                strokeColor: isInhale ? Color(hex: "E3EEFF", alpha: 0.67) : Color(hex: "FBE7C7", alpha: 0.67)
            )
            .frame(width: 375, height: 142)
            .penPosition(792, 72)
        }
        .multilineTextAlignment(.center)
    }
}

private struct MovePlayResultCanvas: View {
    let snapshot: MoveSessionSnapshot
    let variant: MovePlayScreenVariant
    let activeRouteHint: String
    let repsValueText: String
    let repsLeftText: String
    let goalHintText: String
    let resultHeadline: String
    let resultCueTitle: String
    let resultCueSubtitle: String
    let resultRouteHint: String
    let onRetryTomorrow: () -> Void
    let onFinish: () -> Void

    private var isSkipped: Bool { variant == .resultSkipped }
    private var routeVisualSpec: RouteVisualSpec {
        if isSkipped {
            return RouteVisualSpec.result(for: variant, hint: routeHint)
        }
        // Keep the same route gauge style used during active SIT-TO-STAND,
        // and only show it as fully completed.
        return RouteVisualSpec.active(for: .exhaleActive, hint: activeRouteHint)
    }

    private var screenTitle: String {
        isSkipped ? "SAFETY SKIP" : "SIT-TO-STAND"
    }

    private var headlineText: String {
        isSkipped
            ? "Movement was skipped for safety.\nYour breathing progress is still saved."
            : resultHeadline
    }

    private var cueTitle: String {
        isSkipped ? "Safety decision recorded." : resultCueTitle
    }

    private var cueSubtitle: String {
        isSkipped ? "You can finish now or retry when breathing feels steady." : resultCueSubtitle
    }

    private var routeHint: String {
        isSkipped ? "You chose safety first. Resume movement next session if ready." : resultRouteHint
    }

    private var assistiveHint: String {
        isSkipped
            ? "Skipping for safety is a successful self-care choice."
            : "Hydrate and rest briefly before your next activity."
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            MoveSessionPillRow(mode: .result)
                .frame(width: 370, height: 44)
                .penPosition(412, 16)

            Text(screenTitle)
                .font(.system(size: isSkipped ? 82 : 76, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                .shadow(color: Color.black.opacity(0.36), radius: 12, y: 4)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
                .frame(width: MovePlayCanvas.width, alignment: .center)
                .penPosition(0, 214)

            Text(headlineText)
                .font(.system(size: isSkipped ? 28 : 26, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                .shadow(color: Color.black.opacity(0.26), radius: 8, y: 2)
                .frame(width: MovePlayCanvas.width, alignment: .center)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .minimumScaleFactor(0.84)
                .lineLimit(3)
                .penPosition(0, 326)

            MoveCueCard(
                title: cueTitle,
                subtitle: cueSubtitle,
                topColor: Color(hex: "F5DFB7", alpha: 0.69),
                bottomColor: Color(hex: "6A5145", alpha: 0.54),
                strokeColor: Color(hex: "FFEAC7", alpha: 0.67),
                titleColor: Color(hex: "FFF8EC"),
                subtitleColor: Color(hex: "FFEED1"),
                titleSize: 32,
                subtitleSize: 15
            )
            .frame(width: 420, height: 86)
            .penPosition(387, 414)

            if let routeLabelText = routeVisualSpec.routeLabelText {
                Text(routeLabelText)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(routeVisualSpec.routeLabelColor)
                    .penPosition(routeVisualSpec.routeLabelX, 526)
            }

            MoveRouteCard(
                hint: routeVisualSpec.hint,
                topColor: routeVisualSpec.routeCardTopColor,
                bottomColor: routeVisualSpec.routeCardBottomColor,
                strokeColor: routeVisualSpec.routeCardStrokeColor,
                hintColor: routeVisualSpec.routeCardHintColor,
                lineColor: routeVisualSpec.routeCardLineColor,
                lineThickness: routeVisualSpec.routeCardLineThickness,
                hintWidth: routeVisualSpec.routeCardHintWidth,
                hintX: routeVisualSpec.routeCardHintX,
                hintWeight: routeVisualSpec.routeCardHintWeight,
                showStartLabel: routeVisualSpec.routeCardShowStartLabel,
                startLabelColor: routeVisualSpec.routeCardStartLabelColor
            )
            .frame(width: 940, height: 128)
            .penPosition(132, 560)

            MoveHarborLane(
                litCount: max(snapshot.beaconLitCount, 1),
                progressRatio: isSkipped ? snapshot.progressRatio : 1.0,
                style: routeVisualSpec.harborLaneStyle,
                routeLineColorOverride: routeVisualSpec.harborRouteLineColor,
                pulseColorOverride: routeVisualSpec.harborPulseColor
            )
            .frame(width: 490, height: 58)
            .penPosition(352, 576)

            if isSkipped {
                MoveSkippedControlBar(
                    onRetryTomorrow: onRetryTomorrow,
                    onFinish: onFinish
                )
                .frame(width: 490, height: 96)
                .penPosition(352, 708)
            } else {
                MoveFinishControlButton(onTap: onFinish)
                    .frame(width: 490, height: 96)
                    .penPosition(352, 708)
            }

            Text(assistiveHint)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "F6EEDF"))
                .minimumScaleFactor(0.82)
                .lineLimit(1)
                .frame(width: MovePlayCanvas.width, alignment: .center)
                .penPosition(0, 802)

            MoveRepsCard(
                title: isSkipped ? "REPS STATUS" : "REPS COMPLETED",
                valueText: isSkipped ? "Skipped" : repsValueText,
                rightHint: isSkipped ? "Safety skip" : goalHintText,
                leftHint: isSkipped ? "Log: Saved" : repsLeftText,
                progressRatio: isSkipped ? 0.55 : 1.0,
                valueColor: Color(hex: "FFF9ED"),
                fillColor: Color(hex: "FFDFA5"),
                topColor: Color(hex: "F8E8CD", alpha: 0.66),
                bottomColor: Color(hex: "835D4E", alpha: 0.66),
                strokeColor: Color(hex: "FBE7C7", alpha: 0.67),
                valueFontSize: isSkipped ? 50 : 56,
                rightHintX: 250,
                leftHintX: isSkipped ? 258 : 244,
                fillWidthOverride: isSkipped ? 172 : nil,
                titleColor: BW2Tokens.ColorPalette.deep900,
                rightHintColor: BW2Tokens.ColorPalette.deep900
            )
            .frame(width: 375, height: 142)
            .penPosition(792, 72)

            Text(routeVisualSpec.rightLabelText)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(routeVisualSpec.homeLabelColor)
                .penPosition(959, 594)

            if let startRetryText = routeVisualSpec.outerStartRetryText {
                Text(startRetryText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(routeVisualSpec.outerStartRetryColor)
                    .penPosition(219, 594)
            }
        }
        .multilineTextAlignment(.center)
    }
}

private struct MovePlayPenBackground: View {
    let phase: MovePhase
    let isResult: Bool
    let reduceMotion: Bool
    let frameSize: CGSize

    private var overlayColors: [Color] {
        if isResult {
            return [
                Color(hex: "112438", alpha: 0.31),
                Color(hex: "1E3E5A", alpha: 0.34),
                Color(hex: "101C33", alpha: 0.56)
            ]
        }

        switch phase {
        case .inhaleSit:
            return [
                BW2Tokens.ColorPalette.overlayCoolTop,
                BW2Tokens.ColorPalette.overlayCoolTop.opacity(0.92),
                BW2Tokens.ColorPalette.overlayCoolBottom
            ]
        case .exhaleStand:
            return [
                BW2Tokens.ColorPalette.overlayWarmTop,
                BW2Tokens.ColorPalette.overlayWarmTop.opacity(0.9),
                BW2Tokens.ColorPalette.overlayWarmBottom
            ]
        }
    }

    private var sunConfig: (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: Color) {
        if isResult {
            return (682, -6, 520, 370, Color(hex: "CDE8FF", alpha: 0.40))
        }

        switch phase {
        case .inhaleSit:
            return (674, 8, 520, 370, Color(hex: "CDE8FF", alpha: 0.40))
        case .exhaleStand:
            return (694, 8, 500, 360, Color(hex: "FFE3AB", alpha: 0.48))
        }
    }

    private func scaledX(_ value: CGFloat) -> CGFloat {
        (value / MovePlayCanvas.width) * max(frameSize.width, 1)
    }

    private func scaledY(_ value: CGFloat) -> CGFloat {
        (value / MovePlayCanvas.height) * max(frameSize.height, 1)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("sit_to_stand_bg")
                .resizable()
                .scaledToFill()
                .frame(width: max(frameSize.width, 1), height: max(frameSize.height, 1))
                .clipped()
                .accessibilityHidden(true)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: overlayColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: max(frameSize.width, 1), height: max(frameSize.height, 1))
                .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.45), value: phase)
                .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.35), value: isResult)
                .accessibilityHidden(true)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [sunConfig.color, Color.clear],
                        center: .center,
                        startRadius: 8,
                        endRadius: 300
                    )
                )
                .frame(width: scaledX(sunConfig.width), height: scaledY(sunConfig.height))
                .penPosition(scaledX(sunConfig.x), scaledY(sunConfig.y))
                .accessibilityHidden(true)
        }
    }
}

private struct MoveSessionPillRow: View {
    enum Mode {
        case active
        case result
    }

    let mode: Mode

    var body: some View {
        HStack(spacing: 12) {
            MoveSessionPill(
                label: "Breathe",
                symbol: "✓",
                symbolColor: Color(hex: "9BE8DE"),
                textColor: Color(hex: "EDE4D8"),
                width: 116,
                textWeight: .medium,
                topColor: Color(hex: "D7C0AB", alpha: 0.45),
                bottomColor: Color(hex: "8A7A71", alpha: 0.50),
                strokeColor: Color(hex: "F6EEE0", alpha: 0.54)
            )

            MoveSessionPill(
                label: "Move",
                symbol: mode == .result ? "✓" : "●",
                symbolColor: mode == .result ? Color(hex: "BDEBE4") : Color(hex: "66E8D9"),
                textColor: mode == .result ? Color(hex: "EDE4D8") : Color(hex: "F7EEDF"),
                width: 98,
                textWeight: mode == .result ? .medium : .semibold,
                topColor: mode == .result ? Color(hex: "CBB6A5", alpha: 0.42) : Color(hex: "D1BAA9", alpha: 0.40),
                bottomColor: mode == .result ? Color(hex: "746A63", alpha: 0.49) : Color(hex: "7F7067", alpha: 0.52),
                strokeColor: mode == .result ? Color(hex: "F1E8D7", alpha: 0.49) : Color(hex: "F6EEE0", alpha: 0.48)
            )

            MoveSessionPill(
                label: "Done",
                symbol: mode == .result ? "●" : "○",
                symbolColor: mode == .result ? Color(hex: "66E8D9") : BW2Tokens.ColorPalette.textOnImageMuted,
                textColor: mode == .result ? Color(hex: "F7EEDF") : Color(hex: "E8DFD2"),
                width: 98,
                textWeight: mode == .result ? .semibold : .medium,
                topColor: mode == .result ? Color(hex: "E7D2B0", alpha: 0.54) : Color(hex: "D1BAA9", alpha: 0.40),
                bottomColor: mode == .result ? Color(hex: "917A62", alpha: 0.64) : Color(hex: "7F7067", alpha: 0.52),
                strokeColor: mode == .result ? Color(hex: "FBE7C8", alpha: 0.66) : Color(hex: "F6EEE0", alpha: 0.48)
            )
        }
    }
}

private struct MoveSessionPill: View {
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

private struct MoveCueCard: View {
    let title: String
    let subtitle: String
    let topColor: Color
    let bottomColor: Color
    let strokeColor: Color
    let titleColor: Color
    let subtitleColor: Color
    var titleSize: CGFloat = 30
    var subtitleSize: CGFloat = 19

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: titleSize, weight: .bold))
                .foregroundStyle(titleColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: subtitleSize, weight: .medium))
                .foregroundStyle(subtitleColor)
                .minimumScaleFactor(0.82)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [topColor, bottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        )
    }
}

private struct MoveRouteCard: View {
    let hint: String
    let topColor: Color
    let bottomColor: Color
    let strokeColor: Color
    let hintColor: Color
    var lineColor: Color = Color(hex: "F4DEAF", alpha: 0.72)
    var lineThickness: CGFloat = 4
    var hintWidth: CGFloat = 520
    var hintX: CGFloat = 210
    var hintWeight: Font.Weight = .medium
    var showStartLabel: Bool = false
    var startLabelColor: Color = Color(hex: "F7EBDD")

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [topColor, bottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)

            Rectangle()
                .fill(lineColor)
                .frame(width: 740, height: lineThickness)
                .penPosition(78, 70)

            Text(hint)
                .font(.system(size: 15, weight: hintWeight))
                .foregroundStyle(hintColor)
                .multilineTextAlignment(.center)
                .frame(width: hintWidth)
                .minimumScaleFactor(0.82)
                .lineLimit(2)
                .penPosition(hintX, 90)

            if showStartLabel {
                Text("Start")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(startLabelColor)
                    .lineLimit(1)
                    .penPosition(78, 32)
            }
        }
    }
}

private enum MoveHarborLaneStyle {
    case activeInhale
    case activeExhale
    case result
    case skipped
}

private struct MoveHarborLane: View {
    let litCount: Int
    let progressRatio: Double
    let style: MoveHarborLaneStyle
    var routeLineColorOverride: Color? = nil
    var pulseColorOverride: Color? = nil
    private let skippedDotCenters: [CGFloat] = [79, 166, 253, 340, 427]

    private var clampedProgress: Double {
        min(1, max(0, progressRatio))
    }

    private var activeTrackProgressWidth: CGFloat {
        386 * CGFloat(clampedProgress)
    }

    private var activeVesselX: CGFloat {
        52 + activeTrackProgressWidth
    }

    private var activePulseColor: Color {
        if let pulseColorOverride {
            return pulseColorOverride
        }
        return style == .activeInhale ? Color(hex: "D9ECFF") : Color(hex: "FFEBC7")
    }

    private var activeRouteLineColor: Color {
        if let routeLineColorOverride {
            return routeLineColorOverride
        }
        return style == .activeInhale ? Color(hex: "C7D9E8", alpha: 0.56) : Color(hex: "E9D9B8", alpha: 0.54)
    }

    private var activeProgressColor: Color {
        style == .activeInhale ? Color(hex: "D8E7F6", alpha: 0.88) : Color(hex: "F4DDAF", alpha: 0.86)
    }

    private var resultProgressWidth: CGFloat {
        340 * CGFloat(clampedProgress)
    }

    private var vesselX: CGFloat {
        42 + resultProgressWidth
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch style {
            case .activeInhale, .activeExhale:
                activeLane
            case .result:
                resultLane
            case .skipped:
                skippedLane
            }
        }
    }

    @ViewBuilder
    private var activeLane: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "E7CFAB", alpha: 0.37), Color(hex: "5E5051", alpha: 0.34)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

        Capsule(style: .continuous)
            .stroke(Color(hex: "F2E5CF", alpha: 0.53), lineWidth: 1)

        Rectangle()
            .fill(activeRouteLineColor)
            .frame(width: 386, height: 6)
            .penPosition(52, 29)

        Rectangle()
            .fill(activeProgressColor)
            .frame(width: activeTrackProgressWidth, height: 6)
            .penPosition(52, 29)

        Circle()
            .fill(activePulseColor.opacity(0.22))
            .frame(width: 40, height: 40)
            .shadow(color: activePulseColor.opacity(0.64), radius: 16)
            .penPosition(activeVesselX - 20, 12)

        Circle()
            .fill(activePulseColor.opacity(0.95))
            .frame(width: 22, height: 22)
            .penPosition(activeVesselX - 11, 21)
    }

    @ViewBuilder
    private var resultLane: some View {
        let waveCrests: [(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: Color)] = [
            (54, 18, 66, 4, Color(hex: "B7D8EE", alpha: 0.40)),
            (116, 36, 52, 3, Color(hex: "A9CBE3", alpha: 0.33)),
            (176, 18, 66, 4, Color(hex: "B7D8EE", alpha: 0.40)),
            (238, 36, 52, 3, Color(hex: "A9CBE3", alpha: 0.33)),
            (298, 18, 66, 4, Color(hex: "B7D8EE", alpha: 0.40)),
            (360, 36, 46, 3, Color(hex: "A9CBE3", alpha: 0.33))
        ]
        let beaconDots: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color)] = [
            (60, 26, 8, Color(hex: "E8D3A0", alpha: 0.38)),
            (126, 25, 9, Color(hex: "EED7A6", alpha: 0.46)),
            (192, 25, 9, Color(hex: "F2DAAB", alpha: 0.55)),
            (258, 24, 10, Color(hex: "F6E0B4", alpha: 0.65)),
            (324, 23, 11, Color(hex: "FCE8C4", alpha: 0.76))
        ]
        let wakeTrails: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color)] = [
            (338, 24, 7, Color(hex: "FFE7BC", alpha: 0.48)),
            (352, 23, 9, Color(hex: "FFE8B9", alpha: 0.60)),
            (368, 22, 11, Color(hex: "FFEAC0", alpha: 0.75))
        ]

        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "34485B", alpha: 0.51),
                        Color(hex: "4A6276", alpha: 0.56),
                        Color(hex: "7B6A54", alpha: 0.60)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

        Capsule(style: .continuous)
            .stroke(Color(hex: "E5EEF8", alpha: 0.66), lineWidth: 1)

        Rectangle()
            .fill(Color(hex: "CFE0ED", alpha: 0.62))
            .frame(width: 404, height: 2)
            .penPosition(40, 30)

        Rectangle()
            .fill(Color(hex: "FFE3B8", alpha: 0.82))
            .frame(width: resultProgressWidth, height: 3)
            .penPosition(40, 30)

        ForEach(waveCrests.indices, id: \.self) { idx in
            let crest = waveCrests[idx]
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(crest.4)
                .frame(width: crest.2, height: crest.3)
                .penPosition(crest.0, crest.1)
        }

        ForEach(beaconDots.indices, id: \.self) { idx in
            let dot = beaconDots[idx]
            Circle()
                .fill(dot.3)
                .frame(width: dot.2, height: dot.2)
                .penPosition(dot.0, dot.1)
        }

        ForEach(wakeTrails.indices, id: \.self) { idx in
            let trail = wakeTrails[idx]
            Circle()
                .fill(trail.3)
                .frame(width: trail.2, height: trail.2)
                .penPosition(trail.0, trail.1)
        }

        Circle()
            .fill(Color(hex: "FFF0CC"))
            .frame(width: 20, height: 20)
            .shadow(color: Color(hex: "FFE8B8", alpha: 0.85), radius: 18)
            .overlay {
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: "7C5A28"))
                    .accessibilityHidden(true)
            }
            .penPosition(vesselX, 18)

        Circle()
            .fill(Color(hex: "FFEDC3", alpha: 0.49))
            .frame(width: 30, height: 30)
            .shadow(color: Color(hex: "FFE5B6", alpha: 0.75), radius: 20)
            .penPosition(424, 14)

        Circle()
            .fill(Color(hex: "FFF4D7"))
            .frame(width: 14, height: 14)
            .penPosition(432, 22)

        Image(systemName: "triangle.fill")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Color(hex: "FFEFD0"))
            .rotationEffect(.degrees(90))
            .penPosition(458, 24)
    }

    @ViewBuilder
    private var skippedLane: some View {
        let skippedDots: [Color] = [
            Color(hex: "F7DB9B"),
            Color(hex: "F3D494"),
            Color(hex: "F0CD8A"),
            Color(hex: "ECD592"),
            Color(hex: "FFE9BA")
        ]

        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "F3E0BE", alpha: 0.46), Color(hex: "6E5E4E", alpha: 0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

        Capsule(style: .continuous)
            .stroke(Color(hex: "F5E8D2", alpha: 0.65), lineWidth: 1)

        Rectangle()
            .fill(Color(hex: "F2DEB1", alpha: 0.79))
            .frame(width: 386, height: 3)
            .penPosition(52, 29)

        ForEach(Array(skippedDotCenters.enumerated()), id: \.offset) { index, centerX in
            Circle()
                .fill(skippedDots[index])
                .frame(width: 14, height: 14)
                .penPosition(centerX - 7, 22)
        }

        Circle()
            .fill(Color(hex: "FFF1CF"))
            .frame(width: 30, height: 30)
            .shadow(color: Color(hex: "FFE8B8", alpha: 0.80), radius: 18)
            .penPosition(402, 14)
    }
}

private struct MoveRepsCard: View {
    let title: String
    let valueText: String
    let rightHint: String
    let leftHint: String
    let progressRatio: Double
    let valueColor: Color
    let fillColor: Color
    let topColor: Color
    let bottomColor: Color
    let strokeColor: Color
    var valueFontSize: CGFloat = 56
    var rightHintX: CGFloat = 268
    var leftHintX: CGFloat = 287
    var fillWidthOverride: CGFloat? = nil
    var titleColor: Color = BW2Tokens.ColorPalette.textOnImageSecondary
    var rightHintColor: Color = BW2Tokens.ColorPalette.textOnImageSecondary

    private var clampedProgress: Double {
        min(1, max(0, progressRatio))
    }

    private var fillWidth: CGFloat {
        fillWidthOverride ?? (315 * CGFloat(clampedProgress))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .penPosition(28, 16)

            Text(rightHint)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(rightHintColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .penPosition(rightHintX, 17)

            Text(valueText)
                .font(.system(size: valueFontSize, weight: .bold))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
                .penPosition(28, 36)

            Text(leftHint)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(hex: "FFE8C4"))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .penPosition(leftHintX, 93)

            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.27))
                .frame(width: 315, height: 10)
                .penPosition(30, 114)

            Capsule(style: .continuous)
                .fill(fillColor)
                .frame(width: fillWidth, height: 10)
                .penPosition(30, 114)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [topColor, bottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
    }
}

private struct MoveActiveControlBar: View {
    let pauseButtonLabel: String
    let pauseButtonIcon: String
    let onPauseResume: () -> Void
    let onEnd: () -> Void
    let onNeedRest: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            MoveControlButton(
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

            MoveControlButton(
                iconText: "■",
                label: "End",
                width: 118,
                iconColor: Color(hex: "F8F1E8"),
                gradientTop: BW2Tokens.ColorPalette.surfaceOnImageStrong,
                gradientBottom: BW2Tokens.ColorPalette.surfaceOnImageMedium,
                stroke: BW2Tokens.ColorPalette.borderOnImage,
                accessibilityLabel: "End movement mission",
                onTap: onEnd
            )

            MoveControlButton(
                systemIcon: "exclamationmark.triangle.fill",
                label: "Need Rest",
                width: 130,
                iconColor: Color(hex: "FFE3B8"),
                gradientTop: BW2Tokens.ColorPalette.surfaceOnImageStrong,
                gradientBottom: BW2Tokens.ColorPalette.surfaceOnImageMedium,
                stroke: Color(hex: "FFE2B2", alpha: 0.56),
                accessibilityLabel: "Need rest",
                onTap: onNeedRest
            )
        }
    }
}

private struct MoveFinishControlButton: View {
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            MoveControlButton(
                systemIcon: "checkmark.circle.fill",
                label: "Finish",
                width: 486,
                iconColor: Color(hex: "D8FFE3"),
                gradientTop: Color(hex: "5F9E7E", alpha: 0.71),
                gradientBottom: Color(hex: "2F6F53", alpha: 0.72),
                stroke: Color(hex: "BCEFD6", alpha: 0.72),
                textColor: Color(hex: "F3FFF7"),
                labelFontSize: 14,
                labelFontWeight: .bold,
                accessibilityLabel: "Finish move mission",
                onTap: onTap
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct MoveSkippedControlBar: View {
    let onRetryTomorrow: () -> Void
    let onFinish: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            MoveControlButton(
                label: "Retry Tomorrow",
                secondaryLabel: "Keep session safe",
                width: 239,
                iconColor: Color.clear,
                gradientTop: Color(hex: "738EA5", alpha: 0.61),
                gradientBottom: Color(hex: "40596D", alpha: 0.60),
                stroke: Color(hex: "D4E5F9", alpha: 0.61),
                textColor: Color(hex: "F3F9FF"),
                secondaryTextColor: Color(hex: "E0ECF7"),
                accessibilityLabel: "Retry tomorrow",
                onTap: onRetryTomorrow
            )

            MoveControlButton(
                label: "Finish Session",
                secondaryLabel: "Go to summary",
                width: 239,
                iconColor: Color.clear,
                gradientTop: Color(hex: "5F9E7E", alpha: 0.71),
                gradientBottom: Color(hex: "2F6F53", alpha: 0.72),
                stroke: Color(hex: "BCEFD6", alpha: 0.72),
                textColor: Color(hex: "F3FFF7"),
                secondaryTextColor: Color(hex: "D7F8E7"),
                accessibilityLabel: "Finish session",
                onTap: onFinish
            )
        }
    }
}

private struct MoveControlButton: View {
    var iconText: String?
    var systemIcon: String?
    let label: String
    var secondaryLabel: String?
    let width: CGFloat
    let iconColor: Color
    let gradientTop: Color
    let gradientBottom: Color
    let stroke: Color
    var textColor: Color = BW2Tokens.ColorPalette.textOnImageSecondary
    var secondaryTextColor: Color = BW2Tokens.ColorPalette.textOnImageSecondary
    var labelFontSize: CGFloat? = nil
    var labelFontWeight: Font.Weight? = nil
    let accessibilityLabel: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: secondaryLabel == nil ? 1 : 3) {
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
                    .font(
                        .system(
                            size: labelFontSize ?? (secondaryLabel == nil ? 13 : 15),
                            weight: labelFontWeight ?? (secondaryLabel == nil ? .medium : .bold)
                        )
                    )
                    .foregroundStyle(textColor)
                    .minimumScaleFactor(0.82)
                    .lineLimit(1)

                if let secondaryLabel {
                    Text(secondaryLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(secondaryTextColor)
                        .minimumScaleFactor(0.82)
                        .lineLimit(1)
                }
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

private extension View {
    func penPosition(_ x: CGFloat, _ y: CGFloat) -> some View {
        offset(x: x, y: y)
    }
}

#Preview("Move Play Sit-to-Stand") {
    NavigationStack {
        MovePlaySitToStandView(viewModel: MovePlayViewModel())
    }
    .frame(width: 1194, height: 834)
}
