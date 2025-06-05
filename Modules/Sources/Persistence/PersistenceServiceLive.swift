import Foundation

// swiftlint:disable async_without_await

struct PersistenceServiceLive: PersistenceService {
    nonisolated(unsafe) let suite: UserDefaults = {
        UserDefaults(suiteName: "ro.mihaicris.Instagram.PersistenceService") ?? .standard
    }()

    func save(value: Data, for key: String) async throws {
        suite.set(value, forKey: key)
    }

    func get(for key: String) async throws -> Data? {
        suite.data(forKey: key)
    }
}
