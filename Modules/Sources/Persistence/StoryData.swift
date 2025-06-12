// Story Info to be persistwed between app sessions
public struct StoryData: Sendable, Codable {
    public let userId: Int
    public let liked: Bool
    public let seen: Bool

    public init(userId: Int, liked: Bool, seen: Bool) {
        self.userId = userId
        self.liked = liked
        self.seen = seen
    }
}
