import Foundation

// Model to persist between sessions
// Model persisted is always seen, either liked or not liked.
struct StoryPersisted: Codable {
    let id: Int
    let liked: Bool
}
