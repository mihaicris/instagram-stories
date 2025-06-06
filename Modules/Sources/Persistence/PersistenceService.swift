import Dependencies
import Foundation

public protocol PersistenceService: Sendable {
    func persistStoryData(_ data: StoryPersistedData) async throws
    func clearStoryData(_ data: StoryPersistedData) async throws
    func getPersistedStoryData(userID: Int) async throws -> StoryPersistedData?
    
}

extension DependencyValues {
    public enum PersistenceServiceKey: DependencyKey {
        public static let liveValue: PersistenceService = PersistenceServiceLive()
    }

    public var persistenceService: PersistenceService {
        get { self[PersistenceServiceKey.self] }
        set { self[PersistenceServiceKey.self] = newValue }
    }
}
