import Foundation

struct StoryItemViewModel: Identifiable, Equatable, Sendable {
    let id: Int
    let imageURL: URL
    let username: String
    var seen: Bool
    let onTap: @Sendable () async -> Void
    let onAppear: @Sendable () async -> Void
    
    mutating func markAsSeen() {
        seen = true
    }
    
    mutating func markAsUnseen() {
        seen = false
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.imageURL == rhs.imageURL && lhs.username == rhs.username && lhs.seen == rhs.seen
    }
}
