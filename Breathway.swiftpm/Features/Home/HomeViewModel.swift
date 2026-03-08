import SwiftUI

struct WeekDayProgress: Identifiable {
    let id = UUID()
    let label: String
    let isToday: Bool
    let isCompleted: Bool
}

struct MissionCardData {
    let label: String
    let title: String
    let ctaTitle: String
}

struct HomeViewData {
    let streakText: String
    let dateText: String
    let mission: MissionCardData
    let weekDays: [WeekDayProgress]
    let disclaimerLines: [String]
}

extension HomeViewData {
    static let missionDefault = MissionCardData(
        label: "TODAY'S MISSION",
        title: "Breathe 60s\n+ Move 90s",
        ctaTitle: "Start Today's\nMission"
    )

    static let disclaimerDefault = [
        "This app does not provide medical diagnosis or treatment.",
        "Please stop if you feel dizzy or unwell.",
    ]

    static let mock = HomeViewData(
        streakText: "🔥 3-Day Streak",
        dateText: "Feb 19",
        mission: missionDefault,
        weekDays: [
            .init(label: "Mon", isToday: false, isCompleted: true),
            .init(label: "Tue", isToday: false, isCompleted: true),
            .init(label: "Wed", isToday: false, isCompleted: true),
            .init(label: "Thu", isToday: true, isCompleted: true),
            .init(label: "Fri", isToday: false, isCompleted: true),
            .init(label: "Sat", isToday: false, isCompleted: true),
            .init(label: "Sun", isToday: false, isCompleted: true),
        ],
        disclaimerLines: disclaimerDefault
    )
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var data: HomeViewData
    @Published private(set) var missionTipState: RespiratoryTipState = .idle

    private let streakStore: HomeStreakStoring
    private let calendar: Calendar
    private let tipService = RespiratoryTipService()
    private var hasLoadedMissionTip = false

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

    init(
        streakStore: HomeStreakStoring = HomeStreakStore(),
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.streakStore = streakStore

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = .autoupdatingCurrent
        calendar.firstWeekday = 2
        self.calendar = calendar

        self.data = .mock
        refreshHomeData(now: nowProvider())
    }

    func onStartTapped() -> AppRoute {
        print("ONSTart")
        return .readiness
    }

    func refreshHomeData(now: Date = Date()) {
        let completedDays = streakStore.allCompletedDays()
        let streakCount = currentStreakCount(today: now, completedDays: completedDays)
        let weekDays = makeCurrentWeekDays(today: now, completedDays: completedDays)

        data = HomeViewData(
            streakText: "🔥 \(streakCount)-Day Streak",
            dateText: headerDateFormatter.string(from: now),
            mission: HomeViewData.missionDefault,
            weekDays: weekDays,
            disclaimerLines: HomeViewData.disclaimerDefault
        )
    }

    func markMissionCompletedToday(now: Date = Date()) {
        streakStore.markCompleted(on: now)
        refreshHomeData(now: now)
    }

    func loadMissionTipIfNeeded() async {
        guard !hasLoadedMissionTip else { return }
        hasLoadedMissionTip = true
        missionTipState = .loading
        let tip = await tipService.generateTip(context: .homeMission)
        missionTipState = .loaded(tip)
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
}
