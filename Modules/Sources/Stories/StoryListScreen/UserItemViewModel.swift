import Foundation

struct UserItemViewModel: Identifiable, Equatable {
    let id: Int
    let imageURL: URL
    let body: String
    let seen: Bool
    let onTap: () async -> Void
    let onAppear: () async -> Void

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.imageURL == rhs.imageURL && lhs.body == rhs.body && lhs.seen == rhs.seen
    }
}
