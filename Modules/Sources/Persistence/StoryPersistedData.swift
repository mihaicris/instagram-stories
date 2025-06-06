// Story Data to persist between sessions
// Note: - if story is not persisted, it means it has not been seen
public struct StoryPersistedData: Sendable {
    public let userID: Int
    public let liked: Bool
    
    public init(userID: Int, liked: Bool) {
        self.userID = userID
        self.liked = liked
    }
}
