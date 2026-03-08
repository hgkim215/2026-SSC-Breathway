import Foundation

struct MissionDayKey: Hashable, Codable, Sendable {
    let rawValue: String
}

extension MissionDayKey {
    static func from(_ date: Date, calendar: Calendar) -> MissionDayKey {
        let dayStart = calendar.startOfDay(for: date)
        return MissionDayKey(rawValue: Self.storageFormatter.string(from: dayStart))
    }

    private static let storageFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

protocol HomeStreakStoring {
    func markCompleted(on date: Date)
    func allCompletedDays() -> Set<MissionDayKey>
}

final class HomeStreakStore: HomeStreakStoring {
    private let userDefaults: UserDefaults
    private let calendar: Calendar
    private let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .autoupdatingCurrent,
        storageKey: String = AppStorageKeys.completedMissionDays
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.storageKey = storageKey
    }

    func markCompleted(on date: Date) {
        var dayKeys = allCompletedDays()
        dayKeys.insert(MissionDayKey.from(date, calendar: calendar))
        let serialized = dayKeys
            .map(\.rawValue)
            .sorted()
        userDefaults.set(serialized, forKey: storageKey)
    }

    func allCompletedDays() -> Set<MissionDayKey> {
        let rawKeys = userDefaults.stringArray(forKey: storageKey) ?? []
        return Set(rawKeys.map { MissionDayKey(rawValue: $0) })
    }
}
