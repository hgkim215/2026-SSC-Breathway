import SwiftUI

struct MissionCardView: View {
    let data: MissionCardData
    let tipState: RespiratoryTipState
    let onStart: () -> Void
    @State private var horizontalTipHeight: CGFloat = 110

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalContent
            verticalContent
        }
        .padding(BW2Tokens.Space.x24)
        .bwLiquidGlass(
            cornerRadius: BW2Tokens.Radius.large,
            strokeColor: BW2Tokens.ColorPalette.borderGlass,
            shadowColor: Color.black.opacity(0.18),
            shadowRadius: 40,
            shadowY: 14
        )
        .onPreferenceChange(MissionTipHeightPreferenceKey.self) { newValue in
            guard newValue > 0 else { return }
            if abs(horizontalTipHeight - newValue) > 0.5 {
                horizontalTipHeight = newValue
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var horizontalContent: some View {
        HStack(spacing: BW2Tokens.Space.x24) {
            missionTextBlock
                .frame(width: 320, alignment: .leading)

            Divider()
                .frame(height: 136)
                .overlay(BW2Tokens.ColorPalette.borderGlass)

            tipBlock
                .frame(width: 300, alignment: .leading)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: MissionTipHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                    }
                )

            startButton
                .frame(width: 230, height: horizontalTipHeight)
        }
    }

    private var verticalContent: some View {
        VStack(alignment: .leading, spacing: BW2Tokens.Space.x20) {
            missionTextBlock
            tipBlock
            startButton
                .frame(maxWidth: .infinity, minHeight: BW2Tokens.Size.buttonMin)
        }
    }

    private var missionTextBlock: some View {
        VStack(alignment: .leading, spacing: BW2Tokens.Space.x12) {
            Text(data.label)
                .font(BW2Tokens.Typography.missionLabel)
                .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)

            Text(data.title)
                .font(BW2Tokens.Typography.missionTitle)
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineSpacing(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var tipBlock: some View {
        RespiratoryTipCard(
            title: "TODAY'S RESPIRATORY TIP",
            state: tipState,
            compact: true,
            tone: .onGlass
        )
    }

    private var startButton: some View {
        Button(action: onStart) {
            HStack(spacing: BW2Tokens.Space.x14) {
                Text(data.ctaTitle)
                    .font(BW2Tokens.Typography.button18)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: BW2Tokens.Space.x8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundStyle(BW2Tokens.ColorPalette.textInverse)
            .padding(.horizontal, BW2Tokens.Space.x24)
            .padding(.vertical, BW2Tokens.Space.x16)
            .frame(maxWidth: .infinity, minHeight: BW2Tokens.Size.buttonMin, maxHeight: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [BW2Tokens.ColorPalette.teal500, BW2Tokens.ColorPalette.teal400],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: BW2Tokens.Radius.medium, style: .continuous)
            )
            .shadow(color: BW2Tokens.ColorPalette.teal500.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start Today's Mission")
    }
}

private struct MissionTipHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 110

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    MissionCardView(data: HomeViewData.mock.mission, tipState: .loading) {}
        .padding()
        .background(Color(hex: "E6EDF2"))
}
