import Foundation

struct User: Codable, Identifiable, Sendable, Equatable {
    let id: Int
    let name: String
    let profilePictureURL: String

    init(id: Int, name: String, profilePictureURL: String) {
        self.id = id
        self.name = name
        self.profilePictureURL = profilePictureURL
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePictureURL = "profile_picture_url"
    }
}
