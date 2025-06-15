import Foundation

// swiftlint:disable async_without_await

public struct PersistenceServiceUserDefaults: PersistenceService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    nonisolated(unsafe) private let suite: UserDefaults = {
        UserDefaults(suiteName: "ro.mihaicris.Instagram.PersistenceService") ?? .standard
    }()

    public func persistStoryData(_ data: StoryData) async throws {
        let encoded = try encoder.encode(data)
        suite.set(encoded, forKey: data.userID.description)
    }

    public func clearStoryData(_ data: StoryData) async throws {
        suite.set(nil, forKey: data.userID.description)
    }

    public func getPersistedStoryData(userId: Int) async throws -> StoryData? {
        guard let encoded = suite.data(forKey: userId.description) else {
            return nil
        }
        let storyData = try decoder.decode(StoryData.self, from: encoded)
        return storyData
    }
}
