import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onStart: (AppRoute) -> Void
    let onOpenOnboarding: () -> Void
    let onOpenWeeklyProgress: () -> Void
    let isBackgroundMusicEnabled: Bool
    let onToggleBackgroundMusic: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let componentWidth = max(0, proxy.size.width - 96)

            ZStack {
                HomeBackgroundView()

                VStack(spacing: 0) {
                    Spacer(minLength: max(8, safeTop + 8 + BW2Tokens.Size.globalTopContentInset))

                    HomeHeaderView(
                        streakText: viewModel.data.streakText,
                        dateText: viewModel.data.dateText,
                        onTapOnboarding: onOpenOnboarding,
                        isBackgroundMusicEnabled: isBackgroundMusicEnabled,
                        onToggleBackgroundMusic: onToggleBackgroundMusic
                    )
                    .frame(width: componentWidth)

                    Spacer(minLength: 32)

                    MissionCardView(data: viewModel.data.mission, tipState: viewModel.missionTipState) {
                        onStart(viewModel.onStartTapped())
                    }
                    .frame(width: componentWidth)

                    Spacer(minLength: 24)

                    WeekCapsuleView(days: viewModel.data.weekDays)

                    Spacer(minLength: 14)

                    WeeklyProgressButtonView(onTap: onOpenWeeklyProgress)
                        .frame(width: min(componentWidth, 480))

                    Spacer(minLength: 12)

                    DisclaimerView(lines: viewModel.data.disclaimerLines)

                    Spacer(minLength: max(8, safeBottom + 8))
                }
                .padding(.horizontal, BW2Tokens.Space.x20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.refreshHomeData()
        }
        .task {
            await viewModel.loadMissionTipIfNeeded()
        }
        .accessibilityElement(children: .contain)
    }
}

struct HomeBackgroundView: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

//            LinearGradient(
//                colors: [
//                    BW2Tokens.ColorPalette.overlayWarmTop,
//                    BW2Tokens.ColorPalette.overlayCoolTop.opacity(0.78),
//                    BW2Tokens.ColorPalette.overlayCoolBottom,
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            Ellipse()
//                .fill(
//                    RadialGradient(
//                        colors: [
//                            Color(hex: "FFEBD2", alpha: 0.34),
//                            Color(hex: "FFEBD2", alpha: 0.0),
//                        ],
//                        center: .center,
//                        startRadius: 8,
//                        endRadius: 320
//                    )
//                )
//                .frame(width: 620, height: 420)
//                .offset(x: -390, y: 150)
//
//            Ellipse()
//                .fill(
//                    RadialGradient(
//                        colors: [
//                            Color(hex: "FFF4E0", alpha: 0.30),
//                            Color(hex: "FFF4E0", alpha: 0.0),
//                        ],
//                        center: .center,
//                        startRadius: 8,
//                        endRadius: 300
//                    )
//                )
//                .frame(width: 520, height: 420)
//                .offset(x: 350, y: 60)
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(),
        onStart: { _ in },
        onOpenOnboarding: {},
        onOpenWeeklyProgress: {},
        isBackgroundMusicEnabled: true,
        onToggleBackgroundMusic: {}
    )
}

private struct WeeklyProgressButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BW2Tokens.Space.x10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 16, weight: .semibold))
                    .accessibilityHidden(true)

                Text("Open Weekly Progress")
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: BW2Tokens.Space.x8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
            .padding(.horizontal, BW2Tokens.Space.x16)
            .padding(.vertical, BW2Tokens.Space.x12)
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
            .bwLiquidGlass(
                cornerRadius: BW2Tokens.Radius.pill,
                strokeColor: BW2Tokens.ColorPalette.borderGlass
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Weekly Progress")
    }
}
