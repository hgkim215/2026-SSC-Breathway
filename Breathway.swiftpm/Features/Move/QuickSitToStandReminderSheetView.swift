import SwiftUI

struct QuickSitToStandReminderSheetView: View {
    let profile: SessionIntensityProfile
    let onDismiss: () -> Void

    @State private var dragOffsetY: CGFloat = 0

    private let dismissThreshold: CGFloat = 80

    private var isLightSession: Bool {
        profile.recommendation == .light
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = max(20, proxy.size.width * 0.036)
            let bottomPadding = max(18, proxy.safeAreaInsets.bottom + 8)
            let contentWidth = max(0, proxy.size.width - (horizontalPadding * 2))

            ZStack(alignment: .bottom) {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onDismiss)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: BW2Tokens.Radius.pill, style: .continuous)
                        .fill(BW2Tokens.ColorPalette.fog300)
                        .frame(width: 120, height: 7)
                        .padding(.top, 2)
                        .accessibilityHidden(true)

                    VStack(spacing: 4) {
                        Text("Quick Sit-To-Stand Reminder")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.72)
                            .lineLimit(1)

                        Text("Returning session: review movement rhythm, then continue.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.78)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)

                    MoveQuickReminderBadge(displayName: profile.displayName)

                    MoveQuickReminderRhythmRow(profile: profile)
                        .frame(maxWidth: .infinity)

                    MoveQuickReminderSafetyRow(isLightSession: isLightSession)
                        .frame(maxWidth: .infinity)

                    MoveQuickReminderMiniChecklist(profile: profile)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 2)

                    Text("Tap outside or pull down to continue")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.82)
                        .lineLimit(1)
                        .padding(.top, 4)
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

private struct MoveQuickReminderBadge: View {
    let displayName: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.gold500)
                .accessibilityHidden(true)

            Text("\(displayName) rhythm")
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

private struct MoveQuickReminderRhythmRow: View {
    let profile: SessionIntensityProfile

    private var standText: String {
        "EXHALE · Stand · \(profile.moveStandSecondsLabel)s"
    }

    private var sitText: String {
        "INHALE · Sit · \(profile.moveSitSecondsLabel)s"
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                MoveQuickReminderRhythmPill(
                    text: standText,
                    textColor: Color(hex: "7B4B1E"),
                    fill: Color(hex: "F8E6CE"),
                    stroke: Color(hex: "F4E3CC")
                )

                MoveQuickReminderRhythmPill(
                    text: sitText,
                    textColor: Color(hex: "294B76"),
                    fill: Color(hex: "DDEAF8"),
                    stroke: Color(hex: "D4E4F4")
                )
            }

            VStack(spacing: 10) {
                MoveQuickReminderRhythmPill(
                    text: standText,
                    textColor: Color(hex: "7B4B1E"),
                    fill: Color(hex: "F8E6CE"),
                    stroke: Color(hex: "F4E3CC")
                )

                MoveQuickReminderRhythmPill(
                    text: sitText,
                    textColor: Color(hex: "294B76"),
                    fill: Color(hex: "DDEAF8"),
                    stroke: Color(hex: "D4E4F4")
                )
            }
        }
    }
}

private struct MoveQuickReminderRhythmPill: View {
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
                .minimumScaleFactor(0.72)
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

private struct MoveQuickReminderSafetyRow: View {
    let isLightSession: Bool

    private var safetyMessage: String {
        if isLightSession {
            return "Armrests and partial range are okay. Need Rest or Skip Move anytime."
        }
        return "If symptoms rise, tap Need Rest immediately and recover first."
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("⚠")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.safety500)
                .accessibilityHidden(true)

            Text(safetyMessage)
                .font(.system(size: 15, weight: .semibold))
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

private struct MoveQuickReminderMiniChecklist: View {
    let profile: SessionIntensityProfile

    private var sessionPaceLine: String {
        if profile.recommendation == .light {
            return "Gentle pace is enough; smooth control is the goal"
        }
        return "Steady pace with controlled sit-down each rep"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Quick reset checklist")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(BW2Tokens.ColorPalette.textPrimary)
                .minimumScaleFactor(0.84)
                .lineLimit(1)

            MoveQuickReminderChecklistItem(text: "Feet flat and hip-width stance")
            MoveQuickReminderChecklistItem(text: "Exhale \(profile.moveStandSecondsLabel)s while standing")
            MoveQuickReminderChecklistItem(text: "Inhale \(profile.moveSitSecondsLabel)s while sitting")
            MoveQuickReminderChecklistItem(text: "Goal \(profile.moveConfig.targetReps) reps · \(sessionPaceLine)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.58))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BW2Tokens.ColorPalette.borderGlass, lineWidth: 1)
        )
    }
}

private struct MoveQuickReminderChecklistItem: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(BW2Tokens.ColorPalette.teal500)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)

            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BW2Tokens.ColorPalette.textSecondary)
                .minimumScaleFactor(0.85)
                .lineLimit(2)
        }
    }
}

#Preview("Quick Sit-To-Stand Reminder") {
    ZStack {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        QuickSitToStandReminderSheetView(
            profile: SessionRecommendation.standard.intensityProfile,
            onDismiss: {}
        )
    }
    .frame(width: 1194, height: 834)
}
