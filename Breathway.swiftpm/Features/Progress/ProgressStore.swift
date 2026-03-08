import Foundation

protocol ProgressEventStoring {
    func append(_ event: ProgressSessionEvent)
    func allEvents() -> [ProgressSessionEvent]
    func recentEvents(limit: Int) -> [ProgressSessionEvent]
}

final class ProgressStore: ProgressEventStoring {
    private enum Storage {
        static let maxCount = 300
    }

    private let userDefaults: UserDefaults
    private let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = AppStorageKeys.progressSessionEvents
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    func append(_ event: ProgressSessionEvent) {
        var events = allEvents()
        events.append(event)

        if events.count > Storage.maxCount {
            events.removeFirst(events.count - Storage.maxCount)
        }

        save(events)
    }

    func allEvents() -> [ProgressSessionEvent] {
        guard
            let data = userDefaults.data(forKey: storageKey),
            let events = try? JSONDecoder().decode([ProgressSessionEvent].self, from: data)
        else {
            return []
        }
        return events
    }

    func recentEvents(limit: Int = 50) -> [ProgressSessionEvent] {
        guard limit > 0 else { return [] }
        return Array(allEvents().suffix(limit))
    }

    private func save(_ events: [ProgressSessionEvent]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
