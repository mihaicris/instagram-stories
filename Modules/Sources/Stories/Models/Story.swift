import Foundation

struct Story: Codable, Identifiable {
    let id: Int
    let userID: Int
    let mediaList: [Media]
    let username: String
    let seen: Bool

    struct Media: Codable, Identifiable {
        let id: Int
        let type: String
        let url: URL

        enum `Type`: String, Codable {
            case image
            case video
        }
    }
}
