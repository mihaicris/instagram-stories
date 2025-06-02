import Foundation

struct Story: Codable, Identifiable {
    let id: Int
    let imageURL: URL
    let username: String
    let seen: Bool
}

struct StoryDetails: Codable {
    let id: Int
    let userId: String
    let username: String
    let imageURL: URL
}
