import Dependencies
import Foundation

public protocol PersistenceService: Sendable {
    func save(value: Data, for key: String) async throws
    func get(for key: String) async throws -> Data?
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
