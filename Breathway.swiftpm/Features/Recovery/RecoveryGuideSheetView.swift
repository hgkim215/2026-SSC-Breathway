import SwiftUI

enum RecoveryGuideContext: Equatable {
    case breathing
    case moveSitToStand

    var inhaleDurationSec: Int {
        switch self {
        case .breathing: 4
        case .moveSitToStand: 3
        }
    }

    var exhaleDurationSec: Int {
        switch self {
        case .breathing: 6
        case .moveSitToStand: 3
        }
    }

    var subtitle: String {
        switch self {
        case .breathing:
            "Pause now. Lengthen your exhale, then recheck before restart."
        case .moveSitToStand:
            "Pause now. Stabilize breathing and posture, then restart when ready."
        }
    }
}

struct RecoveryGuideSheetView: View {
    let context: RecoveryGuideContext
    let onRestartSession: () -> Void
    let onBackToHome: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffsetY: CGFloat = 0

    private let dismissThreshold: CGFloat = 88

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = max(20, proxy.size.width * 0.036)
            let bottomPadding = max(14, proxy.safeAreaInsets.bottom + 10)
            let contentWidth = max(0, proxy.size.width - (horizontalPadding * 2))

            ZStack(alignment: .bottom) {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onDismiss)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: BW2Tokens.Radius.pill, style: .continuous)
                        .fill(BW2Tokens.ColorPalette.fog200.opacity(0.92))
                        .frame(width: 120, height: 7)
                        .padding(.top, 2)
                        .accessibilityHidden(true)

                    VStack(spacing: 4) {
                        Text("Recovery Guide")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(context.subtitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                    }
                    .frame(maxWidth: .infinity)

                    RecoveryGuideBadge()

                    RecoveryGuideRhythmRow(
                        inhaleSec: context.inhaleDurationSec,
                        exhaleSec: context.exhaleDurationSec
                    )
                    .frame(maxWidth: .infinity)

                    RecoveryGuideChecklist()
                        .frame(maxWidth: .infinity)

                    RecoveryGuideSafetyRow()
                        .frame(maxWidth: .infinity)

                    RecoveryGuideCTA(
                        onRestartSession: onRestartSession,
                        onBackToHome: onBackToHome
                    )
                    .frame(maxWidth: .infinity)

                    Text("If symptoms persist, skip movement today and continue tomorrow.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .frame(maxWidth: min(1106, contentWidth))
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFFFFF", alpha: 0.93),
                                    Color(hex: "EDF4F9", alpha: 0.91)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .bwAdaptiveGlass(
                    cornerRadius: 32,
                    tint: Color.white.opacity(0.03),
                    strokeColor: BW2Tokens.ColorPalette.borderGlass,
                    shadowColor: Color(hex: "111C2A", alpha: 0.24),
                    shadowRadius: 26,
                    shadowY: 10
                )
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, bottomPadding)
                .offset(y: dragOffsetY)
                .gesture(
                    DragGesture(minimumDistance: 4, coordinateSpace: .global)
                        .onChanged { value in
                            dragOffsetY = max(0, value.translation.height)
                        }
                        .onEnded { value in
                            let downwardDrag = max(0, value.translation.height)
                            if downwardDrag >= dismissThreshold {
                                onDismiss()
                                return
                            }
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
                                dragOffsetY = 0
                            }
                        }
                )
                .accessibilityElement(children: .contain)
            }
        }
        .ignoresSafeArea()
    }
}

private struct RecoveryGuideBadge: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.gold500)
                .accessibilityHidden(true)

            Text("Safety recovery mode")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.86))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
    }
}

private struct RecoveryGuideRhythmRow: View {
    let inhaleSec: Int
    let exhaleSec: Int

    var body: some View {
        HStack(spacing: 10) {
            RecoveryGuideRhythmPill(
                text: "Inhale \(inhaleSec) sec",
                textColor: Color(hex: "294B76"),
                fill: Color(hex: "DDEAF8"),
                stroke: Color(hex: "D4E4F4")
            )

            RecoveryGuideRhythmPill(
                text: "Exhale \(exhaleSec) sec",
                textColor: Color(hex: "7B4B1E"),
                fill: Color(hex: "F8E6CE"),
                stroke: Color(hex: "F4E3CC")
            )
        }
    }
}

private struct RecoveryGuideRhythmPill: View {
    let text: String
    let textColor: Color
    let fill: Color
    let stroke: Color

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(stroke, lineWidth: 1)
        )
    }
}

private struct RecoveryGuideChecklist: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("1. Sit tall. Relax shoulders and jaw.")
            Text("2. Exhale longer than inhale for 5 calm breaths.")
            Text("3. If dizziness stays, stop and hydrate first.")
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: "FFFFFF", alpha: 0.73))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: "D6E2EE"), lineWidth: 1)
        )
    }
}

private struct RecoveryGuideSafetyRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("⚠")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.safety500)
                .accessibilityHidden(true)

            Text("If chest pain or severe shortness of breath appears, end session now.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.safety500)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "FFF3EC"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(hex: "F0C79C"), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct RecoveryGuideCTA: View {
    let onRestartSession: () -> Void
    let onBackToHome: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onRestartSession) {
                HStack(spacing: 10) {
                    Text("Restart Session")
                        .font(.system(size: 17, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.84)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(Color(hex: "F3FFF7"))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "2CD3C5"),
                                    Color(hex: "19BBAE")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(hex: "C6F7F2", alpha: 0.85), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Restart session")

            Button(action: onBackToHome) {
                Text("Back to Home")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: "FFFFFF", alpha: 0.74))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to home")
        }
    }
}

#Preview("Recovery Guide · Move") {
    ZStack {
        Image("sit_to_stand_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        RecoveryGuideSheetView(
            context: .moveSitToStand,
            onRestartSession: {},
            onBackToHome: {},
            onDismiss: {}
        )
    }
    .frame(width: 1194, height: 834)
}
