import SwiftUI

struct ReadinessCheckView: View {
    @StateObject private var viewModel: ReadinessViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(viewModel: ReadinessViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ReadinessBackgroundView()

                ReadinessTemplateView(
                    selection: viewModel.selection,
                    recommendation: viewModel.recommendation,
                    guidanceText: viewModel.guidanceText,
                    guidanceTone: viewModel.guidanceTone,
                    reduceMotion: reduceMotion,
                    onSelect: { domain, level in
                        viewModel.select(level, in: domain)
                    },
                    onAdjust: { domain, direction in
                        viewModel.adjust(direction, in: domain)
                    },
                    onContinue: {
                        viewModel.continueTapped()
                    }
                )
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .sensoryFeedback(.selection, trigger: viewModel.selection)
        .sensoryFeedback(trigger: viewModel.recommendation) { _, newRecommendation in
            switch newRecommendation {
            case .light: .warning
            case .standard: .success
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Template

private struct ReadinessTemplateView: View {
    let selection: ReadinessSelectionState
    let recommendation: SessionRecommendation
    let guidanceText: String
    let guidanceTone: GuidanceTone
    let reduceMotion: Bool
    let onSelect: (ReadinessDomain, ReadinessLevel) -> Void
    let onAdjust: (ReadinessDomain, ReadinessAdjustDirection) -> Void
    let onContinue: () -> Void

    private enum Layout {
        static let paneHorizontalPaddingMin: CGFloat = 20
        static let paneVerticalPaddingMin: CGFloat = 54
        static let paneContentHorizontalInsetMin: CGFloat = 20
        static let guidanceMaxWidth: CGFloat = 648
        static let sessionPlanMaxWidth: CGFloat = 724
        static let ctaMaxWidth: CGFloat = 520
    }

    var body: some View {
        GeometryReader { proxy in
            let isCompactHeight = proxy.size.height <= 820
            let isVeryCompactHeight = proxy.size.height <= 760
            let paneHorizontalPadding = max(Layout.paneHorizontalPaddingMin, proxy.size.width * 0.017)
            let paneVerticalPadding = min(
                Layout.paneVerticalPaddingMin,
                max(isVeryCompactHeight ? 18 : 22, proxy.size.height * (isCompactHeight ? 0.040 : 0.060))
            )
            let paneWidth = max(0, proxy.size.width - (paneHorizontalPadding * 2))
            let paneHeight = max(0, proxy.size.height - (paneVerticalPadding * 2))

            let contentHorizontalInset = max(Layout.paneContentHorizontalInsetMin, paneWidth * 0.02)
            let contentWidth = max(0, paneWidth - (contentHorizontalInset * 2))

            let titleTopInset: CGFloat = isVeryCompactHeight ? 24 : (isCompactHeight ? 30 : max(42, paneHeight * 0.072))
            let subtitleTopSpacing: CGFloat = isCompactHeight ? 8 : max(10, paneHeight * 0.014)
            let cardsTopSpacing: CGFloat = isCompactHeight ? 16 : max(22, paneHeight * 0.032)
            let badgeTopSpacing: CGFloat = isCompactHeight ? 10 : max(14, paneHeight * 0.02)
            let sessionPlanTopSpacing: CGFloat = isCompactHeight ? 10 : max(12, paneHeight * 0.018)
            let guidanceTopSpacing: CGFloat = isCompactHeight ? 10 : max(12, paneHeight * 0.018)
            let ctaTopSpacing: CGFloat = isCompactHeight ? 10 : max(12, paneHeight * 0.018)
            let hintTopSpacing: CGFloat = isCompactHeight ? 8 : max(10, paneHeight * 0.015)
            let titleFontSize: CGFloat = isVeryCompactHeight ? 34 : (isCompactHeight ? 38 : 44)
            let subtitleFontSize: CGFloat = isVeryCompactHeight ? 16 : (isCompactHeight ? 18 : 20)

            ZStack(alignment: .top) {
                ReadinessLiquidPane()
                    .padding(.horizontal, paneHorizontalPadding)
                    .padding(.vertical, paneVerticalPadding)

                VStack(spacing: 0) {
                    Text("How Is Your Body Feeling Today?")
                        .font(.system(size: titleFontSize, weight: .bold))
                        .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)

                    Text("Choose the option that best matches your breathing and energy before starting.")
                        .font(.system(size: subtitleFontSize, weight: .medium))
                        .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .padding(.top, subtitleTopSpacing)

                    ReadinessCardsRowOrganism(
                        selection: selection,
                        reduceMotion: reduceMotion,
                        isCompactHeight: isCompactHeight,
                        onSelect: onSelect,
                        onAdjust: onAdjust
                    )
                    .padding(.top, cardsTopSpacing)

                    RecommendationBadgeMolecule(
                        recommendation: recommendation,
                        isCompactHeight: isCompactHeight
                    )
                        .padding(.top, badgeTopSpacing)

                    SessionPlanCardMolecule(
                        profile: recommendation.intensityProfile,
                        isCompactHeight: isCompactHeight
                    )
                        .frame(maxWidth: min(Layout.sessionPlanMaxWidth, contentWidth * 0.74))
                        .padding(.top, sessionPlanTopSpacing)

                    GuidanceBannerMolecule(
                        text: guidanceText,
                        tone: guidanceTone,
                        isCompactHeight: isCompactHeight
                    )
                    .frame(maxWidth: min(Layout.guidanceMaxWidth, contentWidth * 0.62))
                    .padding(.top, guidanceTopSpacing)

                    ContinueCTAMolecule(
                        isCompactHeight: isCompactHeight,
                        onTap: onContinue
                    )
                        .frame(maxWidth: min(Layout.ctaMaxWidth, contentWidth * 0.5))
                        .padding(.top, ctaTopSpacing)

                    Text("You can change these responses anytime before starting.")
                        .font(.system(size: isCompactHeight ? 12 : 13, weight: .medium))
                        .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                        .minimumScaleFactor(0.9)
                        .padding(.top, hintTopSpacing)
                }
                .padding(.horizontal, paneHorizontalPadding + contentHorizontalInset)
                .padding(.top, paneVerticalPadding + titleTopInset + BW2Tokens.Size.globalTopContentInset)
                .padding(.bottom, paneVerticalPadding + (isCompactHeight ? 8 : 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct ReadinessLiquidPane: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.52),
                        Color.white.opacity(0.42),
                        Color(hex: "EAF2F0", alpha: 0.30)
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
                                Color.white.opacity(0.36),
                                Color.white.opacity(0.0)
                            ],
                            center: .top,
                            startRadius: 12,
                            endRadius: 360
                        )
                    )
                    .frame(height: 220)
            }
            .bwAdaptiveGlass(
                cornerRadius: 32,
                tint: Color.white.opacity(0.05),
                strokeColor: BW2Tokens.ColorPalette.borderOnImage,
                shadowColor: Color(hex: "2B3F4A", alpha: 0.20),
                shadowRadius: 54,
                shadowY: 18
            )
            .allowsHitTesting(false)
    }
}

// MARK: - Organism

private struct ReadinessCardsRowOrganism: View {
    let selection: ReadinessSelectionState
    let reduceMotion: Bool
    let isCompactHeight: Bool
    let onSelect: (ReadinessDomain, ReadinessLevel) -> Void
    let onAdjust: (ReadinessDomain, ReadinessAdjustDirection) -> Void

    var body: some View {
        HStack(spacing: isCompactHeight ? 10 : 12) {
            ForEach(ReadinessDomain.allCases, id: \.self) { domain in
                ReadinessCardOrganism(
                    domain: domain,
                    selected: selection[domain],
                    reduceMotion: reduceMotion,
                    isCompactHeight: isCompactHeight,
                    onSelect: { onSelect(domain, $0) },
                    onAdjust: { onAdjust(domain, $0) }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct ReadinessCardOrganism: View {
    let domain: ReadinessDomain
    let selected: ReadinessLevel
    let reduceMotion: Bool
    let isCompactHeight: Bool
    let onSelect: (ReadinessLevel) -> Void
    let onAdjust: (ReadinessAdjustDirection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: isCompactHeight ? 10 : 14) {
            HStack(spacing: 8) {
                StatusIconAtom(
                    symbolName: domain.symbolName,
                    color: BW2Tokens.ColorPalette.deep700,
                    size: isCompactHeight ? 16 : 18,
                    weight: .semibold
                )

                Text(domain.title)
                    .font(.system(size: isCompactHeight ? 18 : 20, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: isCompactHeight ? 8 : 12) {
                ForEach(ReadinessLevel.allCases) { level in
                    ChoiceChipMolecule(
                        level: level,
                        isSelected: selected == level,
                        reduceMotion: reduceMotion,
                        isCompactHeight: isCompactHeight,
                        onTap: {
                            onSelect(level)
                        }
                    )
                }
            }
        }
        .padding(.vertical, isCompactHeight ? 12 : 18)
        .padding(.horizontal, isCompactHeight ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: BW2Tokens.Radius.medium, style: .continuous)
                .fill(BW2Tokens.ColorPalette.surfaceGlassHigh)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BW2Tokens.Radius.medium, style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(domain.title)
        .accessibilityValue(selected.title)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                onAdjust(.increment)
            case .decrement:
                onAdjust(.decrement)
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Molecule

private struct ChoiceChipMolecule: View {
    let level: ReadinessLevel
    let isSelected: Bool
    let reduceMotion: Bool
    let isCompactHeight: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: isCompactHeight ? 10 : 12) {
                ChoiceDotAtom(
                    isSelected: isSelected,
                    isCompactHeight: isCompactHeight
                )

                ChoiceLabelAtom(
                    text: level.title,
                    isSelected: isSelected,
                    isCompactHeight: isCompactHeight
                )

                Spacer(minLength: 0)
            }
            .padding(.vertical, isCompactHeight ? 8 : 12)
            .padding(.horizontal, isCompactHeight ? 12 : 14)
            .frame(maxWidth: .infinity, minHeight: isCompactHeight ? 48 : BW2Tokens.Size.buttonMin, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BW2Tokens.ColorPalette.chipFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
            )
            .animation(
                reduceMotion ? nil : .easeInOut(duration: BW2Tokens.Motion.fast),
                value: isSelected
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(level.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

private struct RecommendationBadgeMolecule: View {
    let recommendation: SessionRecommendation
    let isCompactHeight: Bool

    var body: some View {
        HStack(spacing: isCompactHeight ? 6 : 8) {
            StatusIconAtom(
                symbolName: "sparkles",
                color: BW2Tokens.ColorPalette.gold500,
                size: isCompactHeight ? 14 : 16,
                weight: .semibold
            )

            Text("Recommended: \(recommendation.label)")
                .font(.system(size: isCompactHeight ? 15 : 16, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.vertical, isCompactHeight ? 8 : 10)
        .padding(.horizontal, isCompactHeight ? 12 : 14)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.92))
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recommended level")
        .accessibilityValue(recommendation.label)
    }
}

private struct SessionPlanCardMolecule: View {
    let profile: SessionIntensityProfile
    let isCompactHeight: Bool
    private var safetyValue: String {
        profile.safetySummaryText ?? "Keep steady form. Pause if symptoms rise."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isCompactHeight ? 8 : 10) {
            HStack(spacing: 8) {
                StatusIconAtom(
                    symbolName: profile.recommendation == .light ? "leaf.circle.fill" : "figure.walk.circle.fill",
                    color: profile.recommendation == .light ? BW2Tokens.ColorPalette.teal500 : BW2Tokens.ColorPalette.gold500,
                    size: isCompactHeight ? 15 : 17,
                    weight: .semibold
                )

                Text("Today's Session Plan · \(profile.displayName)")
                    .font(.system(size: isCompactHeight ? 15 : 16, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }

            SessionPlanRow(title: "Breathing", value: profile.breathingSummaryText, isCompactHeight: isCompactHeight)
            SessionPlanRow(title: "Move", value: profile.moveSummaryText, isCompactHeight: isCompactHeight)
            SessionPlanRow(title: "Cue", value: profile.coachingSummaryText, isCompactHeight: isCompactHeight)
            SessionPlanRow(title: "Safety", value: safetyValue, isCompactHeight: isCompactHeight)
        }
        .padding(.horizontal, isCompactHeight ? 14 : 16)
        .padding(.vertical, isCompactHeight ? 12 : 14)
        .frame(height: isCompactHeight ? 142 : 166, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.86))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today's session plan")
        .accessibilityValue([
            profile.displayName,
            profile.breathingSummaryText,
            profile.moveSummaryText,
            profile.coachingSummaryText,
            safetyValue
        ].joined(separator: ". "))
    }
}

private struct SessionPlanRow: View {
    let title: String
    let value: String
    let isCompactHeight: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: isCompactHeight ? 13 : 14, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.deep700)
                .frame(width: isCompactHeight ? 66 : 72, alignment: .leading)

            Text(value)
                .font(.system(size: isCompactHeight ? 13 : 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GuidanceBannerMolecule: View {
    let text: String
    let tone: GuidanceTone
    let isCompactHeight: Bool

    var body: some View {
        HStack(spacing: isCompactHeight ? 8 : 10) {
            StatusIconAtom(
                symbolName: tone == .safety ? "exclamationmark.triangle" : "checkmark",
                color: tone == .safety ? BW2Tokens.ColorPalette.safety500 : BW2Tokens.ColorPalette.teal500,
                size: isCompactHeight ? 18 : 22,
                weight: .semibold
            )

            Text(text)
                .font(.system(size: isCompactHeight ? 17 : 20, weight: .semibold))
                .foregroundStyle(tone == .safety ? BW2Tokens.ColorPalette.safety500 : BW2Tokens.ColorPalette.deep700)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(isCompactHeight ? 11 : 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tone == .safety ? Color(hex: "FFE7EA") : Color(hex: "E7F8F6"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    tone == .safety ? BW2Tokens.ColorPalette.safety500 : BW2Tokens.ColorPalette.teal500,
                    lineWidth: 1
                )
        )
        .frame(height: isCompactHeight ? 64 : 72)
        .accessibilityElement(children: .combine)
    }
}

private struct ContinueCTAMolecule: View {
    let isCompactHeight: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ctaLabel
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
        .frame(minHeight: isCompactHeight ? 56 : 64)
        .accessibilityLabel("Continue to Mission")
    }

    private var ctaLabel: some View {
        HStack(spacing: isCompactHeight ? 10 : 14) {
            Text("Continue to Mission")
                .font(.system(size: isCompactHeight ? 16 : 17, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)

            StatusIconAtom(
                symbolName: "arrow.right",
                color: BW2Tokens.ColorPalette.textInverse,
                size: isCompactHeight ? 20 : 24,
                weight: .semibold
            )
        }
        .padding(.vertical, isCompactHeight ? 12 : 14)
        .padding(.horizontal, isCompactHeight ? 20 : 24)
    }
}

// MARK: - Atom

private struct ChoiceDotAtom: View {
    let isSelected: Bool
    let isCompactHeight: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.76))
                .frame(width: isCompactHeight ? 20 : 24, height: isCompactHeight ? 20 : 24)
                .overlay(
                    Circle()
                        .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 2)
                )

            if isSelected {
                Circle()
                    .fill(BW2Tokens.ColorPalette.teal400)
                    .frame(width: isCompactHeight ? 10 : 12, height: isCompactHeight ? 10 : 12)
            }
        }
        .frame(width: isCompactHeight ? 28 : 32, height: isCompactHeight ? 28 : 32)
    }
}

private struct ChoiceLabelAtom: View {
    let text: String
    let isSelected: Bool
    let isCompactHeight: Bool

    var body: some View {
        Text(text)
            .font(.system(size: isCompactHeight ? 15 : 16, weight: .semibold))
            .foregroundStyle(isSelected ? BW2Tokens.ColorPalette.textInverse : BW2Tokens.ColorPalette.textInverse.opacity(0.92))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }
}

private struct StatusIconAtom: View {
    let symbolName: String
    let color: Color
    let size: CGFloat
    let weight: Font.Weight

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: size, weight: weight))
            .foregroundStyle(color)
            .accessibilityHidden(true)
    }
}

// MARK: - Background

private struct ReadinessBackgroundView: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .scaleEffect(x: 1.04, y: 1.10, anchor: .center)
                .offset(y: 24)
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
                            Color(hex: "FFEBD2", alpha: 0.48),
                            Color(hex: "FFEBD2", alpha: 0.0)
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 320
                    )
                )
                .frame(width: 620, height: 420)
                .offset(x: -390, y: 174)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFF4E0", alpha: 0.41),
                            Color(hex: "FFF4E0", alpha: 0.0)
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 300
                    )
                )
                .frame(width: 520, height: 420)
                .offset(x: 350, y: 84)
        }
    }
}

// MARK: - Preview

#Preview("ReadinessCheck Standard") {
    NavigationStack {
        ReadinessCheckView(
            viewModel: ReadinessViewModel(
                selection: .default,
                scoreContext: .default
            )
        )
    }
}

#Preview("ReadinessCheck Light") {
    NavigationStack {
        ReadinessCheckView(
            viewModel: ReadinessViewModel(
                selection: ReadinessSelectionState(
                    breathlessness: .severe,
                    fatigue: .mild,
                    confidence: .moderate
                ),
                scoreContext: .default
            )
        )
    }
}
