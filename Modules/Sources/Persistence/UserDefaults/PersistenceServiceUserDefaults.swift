import Foundation

// swiftlint:disable async_without_await

public struct PersistenceServiceUserDefaults: PersistenceService {
    public init() {}

    nonisolated(unsafe) private let suite: UserDefaults = {
        UserDefaults(suiteName: "ro.mihaicris.Instagram.PersistenceService") ?? .standard
    }()

    public func persistStoryData(_ data: StoryPersistedData) async throws {
        suite.set(data.liked, forKey: data.userId.description)
    }

    public func clearStoryData(_ data: StoryPersistedData) async throws {
        suite.set(nil, forKey: data.userId.description)
    }

    public func getPersistedStoryData(userId: Int) async throws -> StoryPersistedData? {
        guard let liked = suite.value(forKey: userId.description) as? Bool else {
            return nil
        }
        return StoryPersistedData(userId: userId, liked: liked)
    }
}
