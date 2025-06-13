import Foundation

struct Story: Codable, Identifiable {
    let id: Int
    let userId: Int
    let content: [Media]
    let seen: Bool
    let liked: Bool

    struct Media: Codable, Identifiable {
        let id: Int
        let type: String
        let url: URL
        let band: String?
        let song: String?

        enum `Type`: String, Codable {
            case image
            case video
        }
    }
}
