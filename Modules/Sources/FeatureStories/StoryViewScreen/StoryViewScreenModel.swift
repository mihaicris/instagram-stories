import Dependencies
import Foundation
import Networking
import Observation
import Persistence

@MainActor
@Observable
final class StoryViewScreenModel {
    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    @ObservationIgnored
    @Dependency(\.persistenceService) private var persistenceService

    @ObservationIgnored
    let story: Story
    
    var liked: Bool = false

    //    let userProfileImageURL: URL
    //    let username: String
    //    let userVerified: Bool
    //    let activeTime: String
    //    let segments: [Segment]
    //    let liked: Bool

    init(story: Story) {
        self.story = story
    }

    func onClose() {
    }

    func onLike() async {
        do {
            liked.toggle()
            let persisted = StoryPersisted(id: 1, liked: liked) // TODO: Fix hardcoded data
            let encoder = JSONEncoder()
            let data = try encoder.encode(persisted)
            try await persistenceService.save(value: data, for: 1.description) // TODO: Fix hardcoded data
            try await apiService.request(.updateStoryLikeStatus(storyID: 1, liked: false))   // TODO: Fix hardcoded data
        } catch {
            liked.toggle() // recover previous state
            dump(error)
        }
    }

    struct ViewModel {
        let userProfileImageURL: URL
        let username: String
        let userVerified: Bool
        let activeTime: String
        let segments: [Segment]
        let liked: Bool
    }

    struct Segment {
        let url: URL
        let type: String
        let musicInfo: String?
    }
}
