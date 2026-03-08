import SwiftUI

struct RecoveryGuidePlaceholderView: View {
    var body: some View {
        ZStack {
            RecoveryPlaceholderBackground()

            VStack(spacing: 16) {
                Text("Recovery Guide")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Safety stop was triggered.\nRecovery flow screen will be implemented in the next slice.")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(32)
            .frame(maxWidth: 780)
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
                tint: Color.white.opacity(0.04),
                strokeColor: BW2Tokens.ColorPalette.borderGlass,
                shadowColor: Color.black.opacity(0.18),
                shadowRadius: 30,
                shadowY: 10
            )
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct RecoveryPlaceholderBackground: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    BW2Tokens.ColorPalette.overlayWarmTop,
                    BW2Tokens.ColorPalette.overlayWarmBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        RecoveryGuidePlaceholderView()
    }
}
