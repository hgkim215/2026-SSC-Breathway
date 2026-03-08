import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var data: ProgressViewData = .placeholder
    @Published private(set) var tipState: RespiratoryTipState = .idle

    private let streakStore: HomeStreakStoring
    private let progressStore: ProgressEventStoring
    private let tipService: RespiratoryTipService
    private let nowProvider: () -> Date
    private let calendar: Calendar
    private var hasLoadedTip = false

    private let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private let weekDayLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private let safetyLogFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "EEE HH:mm"
        return formatter
    }()

    init(
        streakStore: HomeStreakStoring = HomeStreakStore(),
        progressStore: ProgressEventStoring = ProgressStore(),
        tipService: RespiratoryTipService = RespiratoryTipService(),
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.streakStore = streakStore
        self.progressStore = progressStore
        self.tipService = tipService
        self.nowProvider = nowProvider

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = .autoupdatingCurrent
        calendar.firstWeekday = 2
        self.calendar = calendar

        refresh()
    }

    func refresh(now: Date? = nil) {
        let currentDate = now ?? nowProvider()
        let completedDays = streakStore.allCompletedDays()
        let weekDays = makeCurrentWeekDays(today: currentDate, completedDays: completedDays)
        let completedThisWeek = weekDays.filter(\.isCompleted).count
        let weekProgressRatio = Double(completedThisWeek) / 7.0
        let weekCompletionPercent = Int((weekProgressRatio * 100).rounded())
        let streakCount = currentStreakCount(today: currentDate, completedDays: completedDays)
        let safetyEvents = safetyStopEventsThisWeek(today: currentDate)
        let safetyLogLines = makeSafetyLogLines(from: safetyEvents)

        data = ProgressViewData(
            streakText: "🔥 \(streakCount)-Day Streak",
            dateText: headerDateFormatter.string(from: currentDate),
            weekCompletedText: "\(completedThisWeek) / 7 days",
            weekCompletionText: "Week Completion: \(weekCompletionPercent)%",
            weekProgressRatio: weekProgressRatio,
            currentStreakCount: streakCount,
            currentStreakValueText: "\(streakCount) \(streakCount == 1 ? "Day" : "Days")",
            safetyStopsValueText: "\(safetyEvents.count) this week",
            safetyStopsThisWeek: safetyEvents.count,
            safetyLogLines: safetyLogLines,
            weekDays: weekDays,
            disclaimerLines: ProgressViewData.placeholder.disclaimerLines
        )
    }

    func loadTipIfNeeded() async {
        guard !hasLoadedTip else { return }
        hasLoadedTip = true
        tipState = .loading

        let context = RespiratoryTipContext.progressMotivation(
            weekCompletionRate: data.weekProgressRatio,
            streakCount: data.currentStreakCount,
            safetyStopsThisWeek: data.safetyStopsThisWeek
        )
        let tip = await tipService.generateTip(context: context)
        tipState = .loaded(tip)
    }

    private func currentStreakCount(today: Date, completedDays: Set<MissionDayKey>) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: today)

        while completedDays.contains(MissionDayKey.from(cursor, calendar: calendar)) {
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDate
        }

        return streak
    }

    private func makeCurrentWeekDays(today: Date, completedDays: Set<MissionDayKey>) -> [WeekDayProgress] {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else {
                return nil
            }

            return WeekDayProgress(
                label: weekDayLabelFormatter.string(from: date),
                isToday: calendar.isDate(date, inSameDayAs: today),
                isCompleted: completedDays.contains(MissionDayKey.from(date, calendar: calendar))
            )
        }
    }

    private func safetyStopEventsThisWeek(today: Date) -> [ProgressSessionEvent] {
        guard let weekRange = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }

        return progressStore
            .allEvents()
            .filter { event in
                event.outcome == .safetyStop &&
                    event.timestamp >= weekRange.start &&
                    event.timestamp < weekRange.end
            }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func makeSafetyLogLines(from events: [ProgressSessionEvent]) -> [String] {
        guard !events.isEmpty else {
            return ["• No safety stops logged this week."]
        }

        return events.prefix(2).map { event in
            let date = safetyLogFormatter.string(from: event.timestamp)
            let reasonText: String
            if let reason = event.reason, !reason.isEmpty {
                reasonText = reason.replacingOccurrences(of: "_", with: " ")
            } else {
                reasonText = "session stopped"
            }
            return "• \(date)  \(event.kind.title) - \(reasonText)"
        }
    }
}
