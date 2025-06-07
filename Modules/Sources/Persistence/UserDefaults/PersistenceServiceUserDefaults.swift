import Foundation

// swiftlint:disable async_without_await

struct PersistenceServiceUserDefaults: PersistenceService {
    nonisolated(unsafe) let suite: UserDefaults = {
        UserDefaults(suiteName: "ro.mihaicris.Instagram.PersistenceService") ?? .standard
    }()

    func persistStoryData(_ data: StoryPersistedData) async throws {
        suite.set(data.liked, forKey: data.userId.description)
    }

    func clearStoryData(_ data: StoryPersistedData) async throws {
        suite.set(nil, forKey: data.userId.description)
    }

    func getPersistedStoryData(userId: Int) async throws -> StoryPersistedData? {
        guard let liked = suite.value(forKey: userId.description) as? Bool else {
            return nil
        }
        return StoryPersistedData(userId: userId, liked: liked)
    }
}
