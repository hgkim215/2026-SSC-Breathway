import SwiftUI

struct RehabGuideSitToStandView: View {
    @Binding var showGuideBeforeMission: Bool
    let recommendation: SessionRecommendation
    let onStartMission: () -> Void

    init(
        showGuideBeforeMission: Binding<Bool>,
        recommendation: SessionRecommendation = .standard,
        onStartMission: @escaping () -> Void
    ) {
        self._showGuideBeforeMission = showGuideBeforeMission
        self.recommendation = recommendation
        self.onStartMission = onStartMission
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RehabGuideBackgroundView()

                RehabGuideSitToStandTemplate(
                    showGuideBeforeMission: $showGuideBeforeMission,
                    recommendation: recommendation,
                    onStartMission: onStartMission
                )
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .accessibilityElement(children: .contain)
    }
}

private struct RehabGuideSitToStandTemplate: View {
    @Binding var showGuideBeforeMission: Bool
    let recommendation: SessionRecommendation
    let onStartMission: () -> Void

    private var profile: SessionIntensityProfile { recommendation.intensityProfile }

    private enum Layout {
        static let paneHorizontalInset: CGFloat = 20
        static let paneVerticalInset: CGFloat = 54
    }

    var body: some View {
        GeometryReader { proxy in
            let paneHorizontalInset = max(Layout.paneHorizontalInset, proxy.size.width * 0.017)
            let paneVerticalInset = max(Layout.paneVerticalInset, proxy.size.height * 0.086)
            let paneWidth = max(0, proxy.size.width - (paneHorizontalInset * 2))
            let paneHeight = max(0, proxy.size.height - (paneVerticalInset * 2))
            let contentHorizontalInset = max(24, paneWidth * 0.045)

            ZStack(alignment: .top) {
                RehabGuideLiquidPane()
                    .padding(.horizontal, paneHorizontalInset)
                    .padding(.vertical, paneVerticalInset)

                VStack(spacing: 0) {
                    Text("Before You Start: Sit-to-Stand")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.72)
                        .lineLimit(2)
                        .frame(maxWidth: 760)

                    Text("Stand on exhale, sit on inhale. Keep movement smooth, and pause if discomfort rises.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: 960)
                        .padding(.top, 14)

                    MoveGuideBadge()
                        .padding(.top, 18)

                    MoveSessionModeBadge(profile: profile)
                        .padding(.top, 12)

                    HStack(alignment: .top, spacing: max(16, paneWidth * 0.018)) {
                        SitToStandPreviewCard(profile: profile)
                            .frame(maxWidth: min(700, paneWidth * 0.62))

                        VStack(alignment: .leading, spacing: 16) {
                            MoveSafetyNoticeCard()
                            MoveTargetNote(profile: profile)
                        }
                        .frame(maxWidth: min(330, paneWidth * 0.30), alignment: .topLeading)
                    }
                    .padding(.top, max(18, paneHeight * 0.043))

                    Spacer(minLength: max(16, paneHeight * 0.018))

                    MoveGuideToggleRow(isOn: $showGuideBeforeMission)
                        .frame(maxWidth: min(520, paneWidth * 0.54))

                    Text("Returning users can use the compact quick-start sheet.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(BW2Tokens.ColorPalette.textOnImageSecondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)
                        .padding(.top, 12)

                    StartSitToStandButton(onTap: onStartMission)
                        .frame(maxWidth: min(520, paneWidth * 0.54))
                        .padding(.top, 18)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, paneHorizontalInset + contentHorizontalInset)
                .padding(.top, paneVerticalInset + max(32, paneHeight * 0.053) + BW2Tokens.Size.globalTopContentInset)
                .padding(.bottom, paneVerticalInset + 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct RehabGuideLiquidPane: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.72),
                        Color.white.opacity(0.59),
                        Color(hex: "EAF2F0", alpha: 0.43)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.65),
                                Color.white.opacity(0.0)
                            ],
                            center: .top,
                            startRadius: 14,
                            endRadius: 340
                        )
                    )
                    .frame(height: 200)
            }
            .bwAdaptiveGlass(
                cornerRadius: 32,
                tint: Color.white.opacity(0.03),
                strokeColor: BW2Tokens.ColorPalette.borderGlass,
                shadowColor: Color(hex: "2B3F4A", alpha: 0.20),
                shadowRadius: 54,
                shadowY: 18
            )
            .allowsHitTesting(false)
    }
}

private struct MoveGuideBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.gold500)
                .accessibilityHidden(true)

            Text("First-time move guide")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.87))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .bwAdaptiveGlass(
            cornerRadius: BW2Tokens.Radius.pill,
            tint: Color.white.opacity(0.05),
            strokeColor: BW2Tokens.ColorPalette.borderGlass,
            shadowColor: .clear,
            shadowRadius: 0,
            shadowY: 0
        )
        .accessibilityLabel("First-time move guide")
    }
}

private struct MoveSessionModeBadge: View {
    let profile: SessionIntensityProfile

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: profile.recommendation == .light ? "leaf.fill" : "figure.walk")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(profile.recommendation == .light ? BW2Tokens.ColorPalette.teal500 : BW2Tokens.ColorPalette.deep700)
                .accessibilityHidden(true)

            Text("\(profile.displayName) · \(profile.moveSummaryText)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.89))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current session mode")
        .accessibilityValue("\(profile.displayName). \(profile.moveSummaryText)")
    }
}

private struct SitToStandPreviewCard: View {
    let profile: SessionIntensityProfile

    private var repFlowText: String {
        "1-Rep Flow (about \(profile.moveRepSecondsLabel) seconds)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(repFlowText)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.deep700)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("Use a stable chair edge. Keep your core lightly braced and breathe with motion.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                .minimumScaleFactor(0.85)
                .lineLimit(2)

            HStack(spacing: 20) {
                SitToStandPhaseChip(
                    title: "EXHALE · Stand · \(profile.moveStandSecondsLabel)s",
                    description: "Lean slightly forward\nthen stand tall and steady.",
                    titleColor: Color(hex: "7B4B1E"),
                    bodyColor: Color(hex: "855B2D"),
                    gradientTop: Color(hex: "F8E6CE"),
                    gradientBottom: Color(hex: "F3D8B5"),
                    stroke: Color(hex: "F4E3CC")
                )

                SitToStandPhaseChip(
                    title: "INHALE · Sit · \(profile.moveSitSecondsLabel)s",
                    description: "Hinge at hips and\nsit down with control.",
                    titleColor: Color(hex: "294B76"),
                    bodyColor: Color(hex: "315882"),
                    gradientTop: Color(hex: "DDEAF8"),
                    gradientBottom: Color(hex: "C9DDF4"),
                    stroke: Color(hex: "D4E4F4")
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                MoveGuideStepText(text: "1. Feet flat and hip-width; knees track over toes.")
                MoveGuideStepText(text: "2. Exhale as you press through heels to stand.")
                MoveGuideStepText(text: "3. Inhale as you slowly lower back to the chair.")
                MoveGuideStepText(text: "4. Keep chest lifted; avoid dropping into the seat.")
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.83),
                            Color(hex: "E6EFF6", alpha: 0.80)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .shadow(color: Color(hex: "2B3F4A", alpha: 0.15), radius: 26, y: 8)
        .accessibilityElement(children: .contain)
    }
}

private struct SitToStandPhaseChip: View {
    let title: String
    let description: String
    let titleColor: Color
    let bodyColor: Color
    let gradientTop: Color
    let gradientBottom: Color
    let stroke: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(description)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(bodyColor)
                .lineSpacing(2)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [gradientTop, gradientBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(stroke, lineWidth: 1)
        )
    }
}

private struct MoveGuideStepText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.86)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MoveSafetyNoticeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("⚠ Need Rest Signals")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.safety500)
                .lineLimit(1)

            Text("Stop and tap Need Rest if you feel knee/back pain, dizziness, chest tightness, or unusual shortness of breath.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.safety500)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: "FFF3EC"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: "F0C79C"), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct MoveTargetNote: View {
    let profile: SessionIntensityProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target: \(profile.moveConfig.targetReps) controlled reps (about 90 seconds total). Keep each rep smooth rather than fast.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineSpacing(3)
                .minimumScaleFactor(0.8)

            if let safetySummaryText = profile.safetySummaryText {
                Text(safetySummaryText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BW2Tokens.ColorPalette.teal500)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MoveGuideToggleRow: View {
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("Show this guide before Sit-to-Stand mission")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(BW2Tokens.ColorPalette.teal500)
                .accessibilityLabel("Show this guide before Sit-to-Stand mission")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(minHeight: 58)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(BW2Tokens.ColorPalette.surfaceGlassHigh)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
    }
}

private struct StartSitToStandButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            label
                .foregroundStyle(BW2Tokens.ColorPalette.textInverse)
                .background(
                    RoundedRectangle(cornerRadius: BW2Tokens.Radius.medium, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [BW2Tokens.ColorPalette.teal500, BW2Tokens.ColorPalette.teal400],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 64)
        .accessibilityLabel("Start Sit-to-Stand")
    }

    private var label: some View {
        HStack(spacing: 14) {
            Text("Start Sit-to-Stand")
                .font(.system(size: 17, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)

            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .semibold))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 24)
    }
}

private struct RehabGuideBackgroundView: View {
    var body: some View {
        ZStack {
            Image("sit_to_stand_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    BW2Tokens.ColorPalette.overlayWarmTop,
                    BW2Tokens.ColorPalette.overlayCoolTop.opacity(0.78),
                    BW2Tokens.ColorPalette.overlayCoolBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFE2AD", alpha: 0.40),
                            Color(hex: "FFE2AD", alpha: 0.0)
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 320
                    )
                )
                .frame(width: 620, height: 420)
                .offset(x: -90, y: 180)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFDCA9", alpha: 0.34),
                            Color(hex: "FFDCA9", alpha: 0.0)
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 280
                    )
                )
                .frame(width: 520, height: 420)
                .offset(x: 360, y: 90)
        }
    }
}

#Preview("Rehab Guide Sit-to-Stand") {
    NavigationStack {
        RehabGuideSitToStandView(
            showGuideBeforeMission: .constant(true),
            onStartMission: {}
        )
    }
    .frame(width: 1194, height: 834)
}
