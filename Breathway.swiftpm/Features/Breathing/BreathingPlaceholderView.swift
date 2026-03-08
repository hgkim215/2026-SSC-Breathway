import SwiftUI

struct BreathingPlaceholderView: View {
    var body: some View {
        ZStack {
            BreathingPlaceholderBackground()

            VStack(spacing: 16) {
                Text("Breathing Play")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This screen is the next implementation slice.\nYou are now connected from Readiness and BreathGuide.")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(32)
            .frame(maxWidth: 760)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(BW2Tokens.ColorPalette.surfaceGlassHigh)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
            )
            .bwAdaptiveGlass(
                cornerRadius: 28,
                tint: Color.white.opacity(0.03),
                strokeColor: BW2Tokens.ColorPalette.borderGlass,
                shadowColor: Color(hex: "2B3F4A", alpha: 0.18),
                shadowRadius: 34,
                shadowY: 12
            )
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BreathingPlaceholderBackground: View {
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
        }
    }
}

#Preview("Breathing Placeholder") {
    NavigationStack {
        BreathingPlaceholderView()
    }
}
