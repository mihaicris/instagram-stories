// Story Info to be persistwed between app sessions
public struct StoryData: Sendable, Codable {
    public let userID: Int
    public let liked: Bool
    public let seen: Bool

    public init(userID: Int, liked: Bool, seen: Bool) {
        self.userID = userID
        self.liked = liked
        self.seen = seen
    }
}
