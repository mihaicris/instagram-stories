// Story Data to persist between sessions
// Note: - if story is not persisted, it means it has not been seen
public struct StoryPersistedData: Sendable {
    public let userId: Int
    public let liked: Bool
    
    public init(userId: Int, liked: Bool) {
        self.userId = userId
        self.liked = liked
    }
}
