import SwiftUI

private enum ProgressCanvas {
    static let width: CGFloat = 1194
    static let height: CGFloat = 834
}

struct ProgressPlaceholderView: View {
    @StateObject private var viewModel: ProgressViewModel
    let onBackToResult: () -> Void
    let onBackToHome: () -> Void

    init(
        viewModel: ProgressViewModel = ProgressViewModel(),
        onBackToResult: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBackToResult = onBackToResult
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width / ProgressCanvas.width,
                proxy.size.height / ProgressCanvas.height
            )

            ZStack {
                ProgressBackgroundLayer(frameSize: proxy.size)

                ZStack(alignment: .topLeading) {
                    ProgressHeaderBar(
                        streakText: viewModel.data.streakText,
                        dateText: viewModel.data.dateText
                    )
                    .frame(width: 1146, height: 72)
                    .penPosition(24, 20)

                    Text("WEEKLY PROGRESS")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(Color.black)
                        .shadow(color: Color.black.opacity(0.31), radius: 10, y: 4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .frame(width: ProgressCanvas.width, alignment: .center)
                        .penPosition(0, 138)

                    Text("Track consistency, safety patterns, and recovery momentum.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .frame(width: ProgressCanvas.width, alignment: .center)
                        .penPosition(0, 198)

                    ProgressSummaryCard(
                        data: viewModel.data,
                        tipState: viewModel.tipState
                    )
                    .frame(width: 1146, height: 376)
                    .penPosition(24, 236)

                    WeekCapsuleView(days: viewModel.data.weekDays)
                        .frame(width: 1146, height: 120)
                        .penPosition(24, 628)

                    DisclaimerView(lines: viewModel.data.disclaimerLines)
                        .frame(width: 622, alignment: .center)
                        .penPosition(286, 772)
                }
                .frame(width: ProgressCanvas.width, height: ProgressCanvas.height, alignment: .topLeading)
                .scaleEffect(scale, anchor: .center)
                .offset(y: BW2Tokens.Size.globalTopContentInset)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refresh()
        }
        .task {
            await viewModel.loadTipIfNeeded()
        }
    }
}

private struct ProgressBackgroundLayer: View {
    let frameSize: CGSize

    private func scaledX(_ value: CGFloat) -> CGFloat {
        (value / ProgressCanvas.width) * max(frameSize.width, 1)
    }

    private func scaledY(_ value: CGFloat) -> CGFloat {
        (value / ProgressCanvas.height) * max(frameSize.height, 1)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: max(frameSize.width, 1), height: max(frameSize.height, 1))
                .clipped()
                .accessibilityHidden(true)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FBEBD4", alpha: 0.30),
                            Color(hex: "D9E4EE", alpha: 0.10),
                            Color(hex: "1F3E56", alpha: 0.22),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: max(frameSize.width, 1), height: max(frameSize.height, 1))
                .accessibilityHidden(true)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFEBD2", alpha: 0.48),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 340
                    )
                )
                .frame(width: scaledX(620), height: scaledY(420))
                .penPosition(scaledX(-90), scaledY(180))
                .accessibilityHidden(true)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFF4E0", alpha: 0.42),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                )
                .frame(width: scaledX(520), height: scaledY(420))
                .penPosition(scaledX(760), scaledY(90))
                .accessibilityHidden(true)
        }
    }
}

private struct ProgressHeaderBar: View {
    let streakText: String
    let dateText: String

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 18) {
                LogoMarkView(size: 56)

                Text("Breathway")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(hex: "0E1A26"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 24)

            HStack(spacing: 10) {
                Text(streakText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "E0B84E"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)

                Rectangle()
                    .fill(Color(hex: "FFFFFF", alpha: 0.40))
                    .frame(width: 1, height: 28)

                Text(dateText)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color(hex: "F4F9FD"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(height: 66)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(hex: "6C859B", alpha: 0.53))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color(hex: "FFFFFF", alpha: 0.40), lineWidth: 1)
            )
        }
    }
}

private struct ProgressSummaryCard: View {
    let data: ProgressViewData
    let tipState: RespiratoryTipState

    private var motivationTitle: String {
        switch tipState {
        case .idle, .loading:
            "Generating encouragement..."
        case .loaded(let tip):
            tip.headline
        }
    }

    private var motivationSubtitle: String {
        switch tipState {
        case .idle, .loading:
            "On-device when available"
        case .loaded(let tip):
            "[\(tip.source.rawValue)] \(tip.body)"
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = max(proxy.size.width, 1)
            let sidePadding: CGFloat = 32
            let contentWidth = max(cardWidth - (sidePadding * 2), 1)
            let topBlockHeight: CGFloat = 176
            let rowHeight: CGFloat = 84
            let rowGap: CGFloat = 16
            let statRowY = topBlockHeight + rowGap
            let safetyRowY = statRowY + rowHeight + rowGap

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFFFFF", alpha: 0.85),
                                Color(hex: "EAF2F0", alpha: 0.76)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: cardWidth, height: topBlockHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color(hex: "FFFFFF", alpha: 0.40), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "2B3F4A", alpha: 0.18), radius: 28, y: 10)

                Text("Weekly Route Progress")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .penPosition(sidePadding, 28)

                Text(data.weekCompletedText)
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.deep700)
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)
                    .penPosition(sidePadding, 60)

                Text(data.weekCompletionText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(width: contentWidth, alignment: .trailing)
                    .penPosition(sidePadding, 116)

                Capsule(style: .continuous)
                    .fill(Color(hex: "C7D5E1", alpha: 0.27))
                    .frame(width: contentWidth, height: 12)
                    .penPosition(sidePadding, 136)

                Capsule(style: .continuous)
                    .fill(BW2Tokens.ColorPalette.teal500)
                    .frame(width: contentWidth * CGFloat(min(1, max(0, data.weekProgressRatio))), height: 12)
                    .penPosition(sidePadding, 136)
                    .animation(.easeInOut(duration: 0.25), value: data.weekProgressRatio)

                HStack(spacing: 12) {
                    ProgressStatCard(
                        title: "Current Streak",
                        value: data.currentStreakValueText,
                        subtitle: "",
                        cardFill: Color.white.opacity(0.66),
                        strokeColor: Color(hex: "D7E3ED")
                    )

                    ProgressStatCard(
                        title: "Daily Motivation",
                        value: motivationTitle,
                        subtitle: motivationSubtitle,
                        cardFill: Color.white.opacity(0.66),
                        strokeColor: Color(hex: "D7E3ED"),
                        subtitleLineLimit: 2,
                        valueFontSize: 22,
                        subtitleFontSize: 11
                    )

                    ProgressStatCard(
                        title: "Safety Logs",
                        value: data.safetyStopsValueText,
                        subtitle: "",
                        cardFill: Color(hex: "FFF6EE"),
                        strokeColor: Color(hex: "F0D4B2"),
                        valueColor: Color(hex: "D94B57"),
                        titleColor: Color(hex: "D94B57"),
                        valueFontSize: 26
                    )
                }
                .frame(width: contentWidth, height: rowHeight)
                .penPosition(sidePadding, statRowY)

                ProgressSafetyLogCard(lines: data.safetyLogLines)
                    .frame(width: contentWidth, height: rowHeight)
                    .penPosition(sidePadding, safetyRowY)
            }
            .frame(width: cardWidth, height: proxy.size.height, alignment: .topLeading)
        }
    }
}

private struct ProgressStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let cardFill: Color
    let strokeColor: Color
    var valueColor: Color = BW2Tokens.ColorPalette.textPrimary
    var subtitleColor: Color = BW2Tokens.ColorPalette.textSecondary
    var subtitleLineLimit: Int = 1
    var titleColor: Color = Color(hex: "3E556B")
    var titleFontSize: CGFloat = 14
    var valueFontSize: CGFloat = 30
    var valueFontWeight: Font.Weight = .bold
    var subtitleFontSize: CGFloat = 12

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: titleFontSize, weight: .semibold))
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(value)
                .font(.system(size: valueFontSize, weight: valueFontWeight))
                .foregroundStyle(valueColor)
                .lineLimit(2)
                .minimumScaleFactor(0.56)
                .multilineTextAlignment(.center)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: subtitleFontSize, weight: .semibold))
                    .foregroundStyle(subtitleColor)
                    .lineLimit(subtitleLineLimit)
                    .minimumScaleFactor(0.82)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        )
    }
}

private struct ProgressSafetyLogCard: View {
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Safety Stop Log")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.84)

            ForEach(Array(lines.prefix(2)), id: \.self) { line in
                Text(line)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.70))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "D7E3ED"), lineWidth: 1)
        )
    }
}

private extension View {
    func penPosition(_ x: CGFloat, _ y: CGFloat) -> some View {
        offset(x: x, y: y)
    }
}

#Preview {
    NavigationStack {
        ProgressPlaceholderView(
            onBackToResult: {},
            onBackToHome: {}
        )
    }
    .frame(width: 1194, height: 834)
}
