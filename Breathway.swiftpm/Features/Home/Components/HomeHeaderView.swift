import SwiftUI

struct HomeHeaderView: View {
    let streakText: String
    let dateText: String
    let onTapOnboarding: () -> Void
    let isBackgroundMusicEnabled: Bool
    let onToggleBackgroundMusic: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: BW2Tokens.Space.x24) {
                LogoMarkView(size: 56)

                Text("Breathway")
                    .font(BW2Tokens.Typography.brand)
                    .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: BW2Tokens.Space.x16)

            HStack(spacing: BW2Tokens.Space.x12) {
                StreakChipView(streakText: streakText, dateText: dateText)

                Button(action: onToggleBackgroundMusic) {
                    Image(systemName: isBackgroundMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                        .frame(width: 48, height: 48)
                        .bwLiquidGlass(
                            cornerRadius: BW2Tokens.Radius.pill,
                            strokeColor: BW2Tokens.ColorPalette.borderGlass
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isBackgroundMusicEnabled ? "Turn off background music" : "Turn on background music")

                Button(action: onTapOnboarding) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                        .frame(width: 48, height: 48)
                        .bwLiquidGlass(
                            cornerRadius: BW2Tokens.Radius.pill,
                            strokeColor: BW2Tokens.ColorPalette.borderGlass
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open onboarding")
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct StreakChipView: View {
    let streakText: String
    let dateText: String

    var body: some View {
        HStack(spacing: BW2Tokens.Space.x12) {
            Text(streakText)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: "FF8A00"))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Rectangle()
                .fill(BW2Tokens.ColorPalette.borderOnImage.opacity(0.65))
                .frame(width: 1, height: 28)

            Text(dateText)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(BW2Tokens.ColorPalette.deep900)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, BW2Tokens.Space.x16)
        .padding(.vertical, 10)
        .frame(height: 72)
        .bwLiquidGlass(
            cornerRadius: BW2Tokens.Radius.pill,
            strokeColor: BW2Tokens.ColorPalette.borderGlass
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(streakText), \(dateText)")
    }
}

struct LogoMarkView: View {
    let size: CGFloat

    var body: some View {
        Image("lighthouse_mark_source")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#Preview {
    HomeHeaderView(
        streakText: "🔥 3-Day Streak",
        dateText: "Feb 19",
        onTapOnboarding: {},
        isBackgroundMusicEnabled: true,
        onToggleBackgroundMusic: {}
    )
        .padding()
        .background(Color.gray.opacity(0.25))
}
