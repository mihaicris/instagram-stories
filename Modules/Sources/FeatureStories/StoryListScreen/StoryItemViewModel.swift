import Foundation

struct StoryItemViewModel: Identifiable, Equatable, Sendable {
    let id: Int
    let imageURL: URL
    let body: String
    let seen: Bool
    let onTap: @Sendable () async -> Void
    let onAppear: @Sendable () async -> Void

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.imageURL == rhs.imageURL && lhs.body == rhs.body && lhs.seen == rhs.seen
    }
}
