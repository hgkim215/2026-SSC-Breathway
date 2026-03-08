import SwiftUI

private enum OnboardingCanvas {
    static let width: CGFloat = 1194
    static let height: CGFloat = 834
}

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    let onFinish: (Bool) -> Void
    let onClose: () -> Void

    private var spec: OnboardingScreenSpec {
        OnboardingScreenSpec.make(for: viewModel.currentStep)
    }

    var body: some View {
        GeometryReader { proxy in

            ZStack {
                HomeBackgroundView()

                OnboardingCanvasView(
                    spec: spec,
                    stepLabel: "Step \(viewModel.currentIndex + 1) of \(viewModel.steps.count)",
                    onPrimary: handlePrimary,
                    onSecondary: handleSecondary
                )
                .frame(width: OnboardingCanvas.width, height: OnboardingCanvas.height)
                .offset(y: BW2Tokens.Size.globalTopContentInset)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityElement(children: .contain)
    }

    private func handlePrimary() {
        withAnimation(.easeInOut(duration: 0.22)) {
            let finished = viewModel.moveToNextStep()
            if finished {
                onFinish(viewModel.dontShowAgain)
            }
        }
    }

    private func handleSecondary() {
        withAnimation(.easeInOut(duration: 0.22)) {
            switch viewModel.currentStep {
            case .why:
                _ = viewModel.moveToNextStep()
            case .how:
                onFinish(false)
            case .safety:
                viewModel.moveToPreviousStep()
            case .personalizeStart:
                onFinish(false)
            }
        }
    }
}

private struct OnboardingCanvasView: View {
    let spec: OnboardingScreenSpec
    let stepLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFEBD2", alpha: 0.48),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 260
                    )
                )
                .frame(width: 620, height: 420)
                .penPosition(-90, 180)
                .accessibilityHidden(true)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFF4E0", alpha: 0.41),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 250
                    )
                )
                .frame(width: 520, height: 420)
                .penPosition(760, 90)
                .accessibilityHidden(true)

            OnboardingLiquidPane()
                .frame(width: 1154, height: 859)
                .penPosition(20, 33)

            Text(spec.title)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .frame(width: 760, alignment: .center)
                .penPosition(217, 80)

            Text(spec.subtitle)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(width: 760, alignment: .center)
                .penPosition(217, 145)

            OnboardingValueCard(spec: spec)
                .frame(width: 1046, height: 270)
                .penPosition(74, 226)

            OnboardingStepBadge(stepLabel: stepLabel)
                .frame(width: 218)
                .penPosition(488, 526)

            OnboardingAlertCard(spec: spec.alert)
                .frame(width: 854)
                .penPosition(170, 584)

            OnboardingPrimaryButton(title: spec.primaryButtonTitle, onTap: onPrimary)
                .frame(width: 560, height: 64)
                .penPosition(317, 660)

            Button(action: onSecondary) {
                Text(spec.secondaryButtonTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.96))
                    .underline(true, color: Color.white.opacity(0.96))
                    .shadow(color: Color.black.opacity(0.30), radius: 2, y: 1)
            }
            .buttonStyle(.plain)
            .frame(width: 188, alignment: .center)
            .penPosition(503, 736)

            Text(spec.assistiveHint)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.98))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .shadow(color: Color.black.opacity(0.36), radius: 2, y: 1)
                .frame(width: 700, alignment: .center)
                .penPosition(258, 783)
        }
        .frame(width: OnboardingCanvas.width, height: OnboardingCanvas.height)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct OnboardingLiquidPane: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.24),
                        Color.white.opacity(0.16),
                        Color(hex: "EAF2F0", alpha: 0.10),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.20),
                                Color.clear,
                            ],
                            center: .top,
                            startRadius: 12,
                            endRadius: 440
                        )
                    )
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(BW2Tokens.ColorPalette.borderGlass.opacity(0.42), lineWidth: 1)
            )
            .shadow(color: Color(hex: "2B3F4A", alpha: 0.10), radius: 12, y: 6)
            .padding(.trailing, 14)
    }
}

private struct OnboardingValueCard: View {
    let spec: OnboardingScreenSpec

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(spec.valueCardTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)

            HStack(spacing: 12) {
                ForEach(spec.topTiles.indices, id: \.self) { index in
                    OnboardingTopTile(tile: spec.topTiles[index])
                }
            }

            HStack(spacing: 10) {
                ForEach(spec.bottomRows.indices, id: \.self) { index in
                    OnboardingBottomTile(row: spec.bottomRows[index])
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.opacity(0.76))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: "2B3F4A", alpha: 0.14), radius: 20, y: 8)
    }
}

private struct OnboardingTopTile: View {
    let tile: OnboardingTopTileSpec

    var body: some View {
        VStack(spacing: tile.subtitle == nil ? 0 : 3) {
            Text(tile.title)
                .font(.system(size: 21, weight: tile.subtitle == nil ? .semibold : .bold))
                .foregroundStyle(tile.subtitle == nil ? BW2Tokens.ColorPalette.textSecondary : BW2Tokens.ColorPalette.deep700)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            if let subtitle = tile.subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BW2Tokens.ColorPalette.teal500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
            }
        }
        .frame(width: 327, height: 74)
        .background(tile.isHighlighted ? Color(hex: "DDF3EE") : Color.white.opacity(0.67))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tile.isHighlighted ? Color(hex: "9FDACD") : Color(hex: "D7E3ED"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct OnboardingBottomTile: View {
    let row: OnboardingBottomRowSpec

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 16)

            Text(row.leftText)
                .font(.system(size: row.leftFontSize, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer(minLength: 18)

            Text(row.rightText)
                .font(.system(size: row.rightFontSize, weight: .bold))
                .foregroundStyle(row.rightColor)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer(minLength: 16)
        }
        .frame(width: 498, height: 62)
        .background(Color.white.opacity(0.73))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: "D7E3ED"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct OnboardingStepBadge: View {
    let stepLabel: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.gold500)
                .accessibilityHidden(true)

            Text(stepLabel)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(BW2Tokens.ColorPalette.surfaceGlassHigh)
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .clipShape(Capsule(style: .continuous))
    }
}

private struct OnboardingAlertCard: View {
    let spec: OnboardingAlertSpec

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: spec.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(spec.iconColor)
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)

            Text(spec.message)
                .font(.system(size: spec.fontSize, weight: .semibold))
                .foregroundStyle(spec.messageColor)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(spec.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(spec.borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct OnboardingPrimaryButton: View {
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textInverse)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 12)

                Image(systemName: "arrow.right")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textInverse)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [BW2Tokens.ColorPalette.teal500, BW2Tokens.ColorPalette.teal400],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .shadow(color: BW2Tokens.ColorPalette.teal500.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingTopTileSpec {
    let title: String
    let subtitle: String?
    let isHighlighted: Bool
}

private struct OnboardingBottomRowSpec {
    let leftText: String
    let rightText: String
    let rightColor: Color
    let leftFontSize: CGFloat
    let rightFontSize: CGFloat

    init(
        leftText: String,
        rightText: String,
        rightColor: Color,
        leftFontSize: CGFloat = 17,
        rightFontSize: CGFloat = 17
    ) {
        self.leftText = leftText
        self.rightText = rightText
        self.rightColor = rightColor
        self.leftFontSize = leftFontSize
        self.rightFontSize = rightFontSize
    }
}

private struct OnboardingAlertSpec {
    let icon: String
    let message: String
    let backgroundColor: Color
    let borderColor: Color
    let iconColor: Color
    let messageColor: Color
    let fontSize: CGFloat
}

private struct OnboardingScreenSpec {
    let title: String
    let subtitle: String
    let valueCardTitle: String
    let topTiles: [OnboardingTopTileSpec]
    let bottomRows: [OnboardingBottomRowSpec]
    let alert: OnboardingAlertSpec
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let assistiveHint: String

    static func make(for step: OnboardingStep) -> OnboardingScreenSpec {
        switch step {
        case .why:
            OnboardingScreenSpec(
                title: "Start Small, Keep It Daily.",
                subtitle: "For people with breathing discomfort, Breathway turns rehab into one gentle daily routine in 2-3 minutes.",
                valueCardTitle: "Why Breathway",
                topTiles: [
                    .init(title: "Breathing discomfort", subtitle: "COPD-friendly", isHighlighted: true),
                    .init(title: "Daily tiny rehab", subtitle: nil, isHighlighted: false),
                    .init(title: "2-3 min total", subtitle: nil, isHighlighted: false),
                ],
                bottomRows: [
                    .init(leftText: "Core value", rightText: "Sustainable small actions", rightColor: BW2Tokens.ColorPalette.teal500),
                    .init(leftText: "Not crisis response", rightText: "Consistency first", rightColor: BW2Tokens.ColorPalette.textSecondary),
                ],
                alert: .init(
                    icon: "exclamationmark.shield.fill",
                    message: "Wellness coaching for daily practice, not emergency care.",
                    backgroundColor: Color(hex: "FFF5E4"),
                    borderColor: Color(hex: "E5B66C"),
                    iconColor: Color(hex: "C9882E"),
                    messageColor: Color(hex: "7A4E1D"),
                    fontSize: 19
                ),
                primaryButtonTitle: "Continue",
                secondaryButtonTitle: "See how it works",
                assistiveHint: "Built for short daily rehab rhythm, fully offline."
            )

        case .how:
            OnboardingScreenSpec(
                title: "Today's 4-Step Flow",
                subtitle: "Check -> Breathe -> Move -> Result. Standard path usually finishes in about 3 min 30 sec.",
                valueCardTitle: "Today's flow",
                topTiles: [
                    .init(title: "Check", subtitle: "10 sec", isHighlighted: true),
                    .init(title: "Breathe", subtitle: nil, isHighlighted: false),
                    .init(title: "Move 90 sec", subtitle: nil, isHighlighted: false),
                ],
                bottomRows: [
                    .init(leftText: "Move -> Result", rightText: "90 sec + wrap-up", rightColor: BW2Tokens.ColorPalette.teal500),
                    .init(leftText: "Typical completion", rightText: "~3 min 30 sec", rightColor: BW2Tokens.ColorPalette.textSecondary),
                ],
                alert: .init(
                    icon: "checkmark",
                    message: "Flow is designed for one-tap start and clear transitions.",
                    backgroundColor: Color(hex: "E7F8F6"),
                    borderColor: BW2Tokens.ColorPalette.teal500,
                    iconColor: BW2Tokens.ColorPalette.teal500,
                    messageColor: BW2Tokens.ColorPalette.deep700,
                    fontSize: 18
                ),
                primaryButtonTitle: "See Today's Flow",
                secondaryButtonTitle: "Skip intro",
                assistiveHint: "You can pause and resume instantly during mission."
            )

        case .safety:
            OnboardingScreenSpec(
                title: "Safety Comes First",
                subtitle: "You can stop anytime. If symptoms worsen, end immediately and switch to recovery guidance.",
                valueCardTitle: "Safety before movement",
                topTiles: [
                    .init(title: "Stop anytime", subtitle: "Pause or End now", isHighlighted: true),
                    .init(title: "Symptoms worsen", subtitle: nil, isHighlighted: false),
                    .init(title: "End immediately", subtitle: nil, isHighlighted: false),
                ],
                bottomRows: [
                    .init(leftText: "Sit-to-Stand setup", rightText: "Stable chair + armrests", rightColor: BW2Tokens.ColorPalette.teal500),
                    .init(
                        leftText: "Chest pain or severe dizziness",
                        rightText: "Stop and seek help",
                        rightColor: BW2Tokens.ColorPalette.textSecondary,
                        leftFontSize: 15,
                        rightFontSize: 16
                    ),
                ],
                alert: .init(
                    icon: "exclamationmark.shield.fill",
                    message: "This app does not provide medical diagnosis or treatment.",
                    backgroundColor: Color(hex: "FFF0E8"),
                    borderColor: BW2Tokens.ColorPalette.safety500,
                    iconColor: BW2Tokens.ColorPalette.safety500,
                    messageColor: BW2Tokens.ColorPalette.safety500,
                    fontSize: 19
                ),
                primaryButtonTitle: "Review Safety",
                secondaryButtonTitle: "Back to flow",
                assistiveHint: "Safety stop opens Recovery Guide right away."
            )

        case .personalizeStart:
            OnboardingScreenSpec(
                title: "Ready for Today's Mission",
                subtitle: "Breathway suggests Light or Standard from your current condition. You can adjust anytime.",
                valueCardTitle: "Personalized start",
                topTiles: [
                    .init(title: "Readiness check", subtitle: "8-12 sec", isHighlighted: true),
                    .init(title: "Suggested level", subtitle: nil, isHighlighted: false),
                    .init(title: "Light or Standard", subtitle: nil, isHighlighted: false),
                ],
                bottomRows: [
                    .init(leftText: "Permissions on demand", rightText: "Asked only when needed", rightColor: BW2Tokens.ColorPalette.teal500),
                    .init(
                        leftText: "Mic denied? Rhythm-only mode still works.",
                        rightText: "Mission still runs",
                        rightColor: BW2Tokens.ColorPalette.textSecondary,
                        leftFontSize: 15,
                        rightFontSize: 16
                    ),
                ],
                alert: .init(
                    icon: "bell.badge.fill",
                    message: "Notifications and mic are optional; mission works without both.",
                    backgroundColor: Color(hex: "E7F8F6"),
                    borderColor: BW2Tokens.ColorPalette.teal500,
                    iconColor: BW2Tokens.ColorPalette.teal500,
                    messageColor: BW2Tokens.ColorPalette.deep700,
                    fontSize: 18
                ),
                primaryButtonTitle: "Start Today's Mission",
                secondaryButtonTitle: "Not now",
                assistiveHint: "You can change reminders and permissions later in Settings."
            )
        }
    }
}

private extension View {
    func penPosition(_ x: CGFloat, _ y: CGFloat) -> some View {
        offset(x: x, y: y)
    }
}

#Preview {
    OnboardingView(
        onFinish: { _ in },
        onClose: {}
    )
    .frame(width: 1194, height: 834)
}
