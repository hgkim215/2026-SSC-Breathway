import SwiftUI

private enum DailyMissionResultCanvas {
    static let width: CGFloat = 1194
    static let height: CGFloat = 834
}

struct DailyMissionResultView: View {
    let breathSummary: BreathIntensitySummary?
    let moveSummary: MoveSessionSummary?
    let onBackToHome: () -> Void
    let onViewProgress: () -> Void
    @State private var tipState: RespiratoryTipState = .idle
    @State private var hasLoadedTip = false
    private let tipService = RespiratoryTipService()

    private var display: DailyMissionResultDisplayModel {
        DailyMissionResultDisplayModel(
            breathSummary: breathSummary,
            moveSummary: moveSummary,
            streakCount: currentStreakCount
        )
    }

    private var currentStreakCount: Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = .autoupdatingCurrent

        let completedDays = HomeStreakStore(calendar: calendar).allCompletedDays()
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())

        while completedDays.contains(MissionDayKey.from(cursor, calendar: calendar)) {
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDate
        }

        return streak
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width / DailyMissionResultCanvas.width,
                proxy.size.height / DailyMissionResultCanvas.height
            )

            ZStack {
                DailyMissionResultBackground(frameSize: proxy.size)

                ZStack(alignment: .topLeading) {
                    DailyResultTopSummaryCard(display: display)
                        .frame(width: 407, height: 126)
                        .penPosition(248, 56)

                    DailyResultAftercareCard()
                        .frame(width: 407, height: 86)
                        .penPosition(248, 194)

                    DailyResultMetricsCard(display: display, tipState: tipState)
                        .frame(width: 470, height: 578)
                        .penPosition(676, 56)

                    DailyResultControls(
                        onBackToHome: onBackToHome,
                        onViewProgress: onViewProgress
                    )
                    .frame(width: 430, height: 124)
                    .penPosition(382, 678)

                    Text("This app is for wellness support and is not a substitute for professional medical advice.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "E6D2B0", alpha: 0.80))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .penPosition(347, 794)
                }
                .frame(width: DailyMissionResultCanvas.width, height: DailyMissionResultCanvas.height, alignment: .topLeading)
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
        .task {
            await loadResultTipIfNeeded()
        }
    }

    @MainActor
    private func loadResultTipIfNeeded() async {
        guard !hasLoadedTip else { return }
        hasLoadedTip = true
        tipState = .loading

        let isMoveCompleted = moveSummary?.completionReason == .completedByTimer
        let context = RespiratoryTipContext.resultRecovery(isMoveCompleted: isMoveCompleted)
        let tip = await tipService.generateTip(context: context)
        tipState = .loaded(tip)
    }
}

private struct DailyMissionResultBackground: View {
    let frameSize: CGSize

    private func scaledX(_ value: CGFloat) -> CGFloat {
        (value / DailyMissionResultCanvas.width) * max(frameSize.width, 1)
    }

    private func scaledY(_ value: CGFloat) -> CGFloat {
        (value / DailyMissionResultCanvas.height) * max(frameSize.height, 1)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("session_completed_bg_top150")
                .resizable()
                .scaledToFill()
                .frame(width: max(frameSize.width, 1), height: max(frameSize.height, 1))
                .clipped()
                .accessibilityHidden(true)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "A06811", alpha: 0.10),
                            Color(hex: "8C5A12", alpha: 0.12),
                            Color(hex: "11243D", alpha: 0.42),
                            Color(hex: "091426", alpha: 0.56),
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
                            Color(hex: "FFCD57", alpha: 0.30),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 360
                    )
                )
                .frame(width: scaledX(770), height: scaledY(540))
                .penPosition(scaledX(-124), scaledY(24))
                .accessibilityHidden(true)
        }
    }
}

private struct DailyResultTopSummaryCard: View {
    let display: DailyMissionResultDisplayModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(display.summaryLabel)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: "F6D89B"))
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(display.summaryTitle)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color(hex: "F6F2EA"))
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(display.summaryMeta)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "DFE8F4"))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "102033", alpha: 0.59),
                            Color(hex: "2C3E52", alpha: 0.45),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: "E8EFFA", alpha: 0.34), lineWidth: 1)
        )
        .bwAdaptiveGlass(
            cornerRadius: 20,
            tint: Color.white.opacity(0.03),
            strokeColor: Color.clear,
            shadowColor: Color.black.opacity(0.2),
            shadowRadius: 18,
            shadowY: 8
        )
    }
}

private struct DailyResultAftercareCard: View {
    private let chips = ["Hydrate", "2 min cool down", "Log how you feel"]

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Aftercare checklist")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(hex: "F7F0E3"))
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            HStack(spacing: 10) {
                ForEach(chips, id: \.self) { chip in
                    DailyAftercareChip(text: chip)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "122132", alpha: 0.54),
                            Color(hex: "263649", alpha: 0.47),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: "F2F5FB", alpha: 0.40), lineWidth: 1)
        )
        .bwAdaptiveGlass(
            cornerRadius: 20,
            tint: Color.white.opacity(0.03),
            strokeColor: Color.clear,
            shadowColor: Color.black.opacity(0.16),
            shadowRadius: 14,
            shadowY: 6
        )
    }
}

private struct DailyAftercareChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(hex: "F6EEDD"))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.16))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )
    }
}

private struct DailyResultMetricsCard: View {
    let display: DailyMissionResultDisplayModel
    let tipState: RespiratoryTipState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SESSION ENDED")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "F6D796"))
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(display.harborTitle)
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(Color(hex: "F8F4EC"))
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFD868"), Color(hex: "E5B542")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 46, height: 46)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color(hex: "6B4A18"))
                                .accessibilityHidden(true)
                        }
                        .accessibilityHidden(true)

                    Text(display.missionStatus)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color(hex: "EFE5D5"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 1)

                Text(display.durationRow)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: "E8DFCF"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 1)

                RespiratoryTipCard(
                    title: "RECOVERY TIP",
                    state: tipState,
                    compact: true,
                    tone: .onImage
                )
                .frame(height: 126)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: "1E2C3D", alpha: 0.37))
            )

            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 1)

            HStack(spacing: 10) {
                Text(display.streakText)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: "EFE5D5"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 0)

                Image(systemName: "flame.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: "FFCD5F"))
                    .accessibilityHidden(true)
            }

            Text(display.bodyMessage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color(hex: "F7F2E9"))
                .lineSpacing(2)
                .minimumScaleFactor(0.80)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 34)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "122132", alpha: 0.54),
                            Color(hex: "263649", alpha: 0.47),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color(hex: "F2F5FB", alpha: 0.40), lineWidth: 1)
        )
        .bwAdaptiveGlass(
            cornerRadius: 34,
            tint: Color.white.opacity(0.04),
            strokeColor: Color.clear,
            shadowColor: Color(hex: "020712", alpha: 0.40),
            shadowRadius: 28,
            shadowY: 10
        )
    }
}

private struct DailyResultControls: View {
    let onBackToHome: () -> Void
    let onViewProgress: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Button(action: onBackToHome) {
                Text("Ready for Tomorrow")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(hex: "2E2413"))
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FFD95F"), Color(hex: "F1BF3D")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color(hex: "FFE9A5", alpha: 0.82), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ready for tomorrow")

            Button(action: onViewProgress) {
                Text("View Progress")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(hex: "F1D598"))
                    .underline(true, color: Color(hex: "F1D598"))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View progress")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct DailyMissionResultDisplayModel {
    let summaryLabel: String
    let summaryTitle: String
    let summaryMeta: String
    let harborTitle: String
    let missionStatus: String
    let durationRow: String
    let breathRow: String
    let streakText: String
    let bodyMessage: String

    init(
        breathSummary: BreathIntensitySummary?,
        moveSummary: MoveSessionSummary?,
        streakCount: Int
    ) {
        let isMoveCompleted = moveSummary?.completionReason == .completedByTimer
        let repsValue = moveSummary.map { "\($0.completedReps)/\($0.targetReps) reps" } ?? "Move summary unavailable"
        let durationValue = Self.durationString(moveSummary?.durationSec)
        let steadySeconds = breathSummary.map { Int($0.timeInSteadyBandSec.rounded()) }

        self.summaryLabel = "SESSION CLOSED"
        self.summaryTitle = isMoveCompleted
            ? "Harbor log saved successfully."
            : "Harbor log saved for today."
        self.summaryMeta = "\(durationValue) · \(repsValue) · \(Self.steadyMeta(steadySeconds))"
        self.harborTitle = isMoveCompleted ? "Harbor Secured" : "Harbor Logged"
        self.missionStatus = isMoveCompleted ? "Mission Complete" : "Session Ended Early"
        self.durationRow = "Duration: \(durationValue)"
        self.breathRow = Self.breathRowText(from: breathSummary)
        self.streakText = "\(max(0, streakCount))-Day Streak"
        self.bodyMessage = isMoveCompleted
            ? "You kept the light\nsteady today."
            : "You listened to your body\nand stopped safely."
    }

    private static func steadyMeta(_ steadySeconds: Int?) -> String {
        guard let steadySeconds else { return "steady n/a" }
        return "steady \(steadySeconds)s"
    }

    private static func breathRowText(from summary: BreathIntensitySummary?) -> String {
        guard let summary else { return "Breath: summary unavailable" }
        let inhale = Int((summary.avgInhaleEffort * 100).rounded())
        let exhale = Int((summary.avgExhaleEffort * 100).rounded())
        let steady = Int(summary.timeInSteadyBandSec.rounded())
        return "Breath: \(steady)s steady · In \(inhale)% · Ex \(exhale)%"
    }

    private static func durationString(_ seconds: Double?) -> String {
        guard let seconds else { return "0m 00s" }
        let clamped = max(0, Int(seconds.rounded(.down)))
        let minute = clamped / 60
        let second = clamped % 60
        return "\(minute)m " + String(format: "%02ds", second)
    }
}

private extension View {
    func penPosition(_ x: CGFloat, _ y: CGFloat) -> some View {
        offset(x: x, y: y)
    }
}

#Preview {
    NavigationStack {
        DailyMissionResultView(
            breathSummary: BreathIntensitySummary(
                avgInhaleEffort: 0.43,
                avgExhaleEffort: 0.51,
                timeInSteadyBandSec: 24
            ),
            moveSummary: MoveSessionSummary(
                completionReason: .completedByTimer,
                durationSec: 90,
                completedReps: 15,
                targetReps: 15
            ),
            onBackToHome: {},
            onViewProgress: {}
        )
    }
    .frame(width: 1194, height: 834)
}
