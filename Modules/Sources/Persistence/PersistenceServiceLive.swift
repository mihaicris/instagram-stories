import Foundation

// swiftlint:disable async_without_await

struct PersistenceServiceLive: PersistenceService {
    nonisolated(unsafe) let suite: UserDefaults = {
        UserDefaults(suiteName: "ro.mihaicris.Instagram.PersistenceService") ?? .standard
    }()

    func persistStoryData(_ data: StoryPersistedData) async throws {
        suite.set(data.liked, forKey: data.userID.description)
    }
    
    func clearStoryData(_ data: StoryPersistedData) async throws {
        suite.set(nil, forKey: data.userID.description)
    }
    
    func getPersistedStoryData(userID: Int) async throws -> StoryPersistedData? {
        guard let liked = suite.value(forKey: userID.description) as? Bool else {
            return nil
        }
        return StoryPersistedData(userID: userID, liked: liked)
    }
}
