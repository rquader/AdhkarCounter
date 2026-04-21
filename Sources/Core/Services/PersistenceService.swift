import Foundation

protocol Persisting {
    func load() -> AppStateSnapshot
    func save(_ snapshot: AppStateSnapshot)
}

final class PersistenceService: Persisting {
    private let defaults: UserDefaults
    private let key = "adhkar_counter.snapshot.v2"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppStateSnapshot {
        guard
            let data = defaults.data(forKey: key),
            let snapshot = try? JSONDecoder().decode(AppStateSnapshot.self, from: data)
        else {
            return .default
        }
        return snapshot
    }

    func save(_ snapshot: AppStateSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}
