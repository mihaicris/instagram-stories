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
        liked.toggle()
        do {
            let data = StoryPersistedData(userId: story.userId, liked: liked)
            try await apiService.request(.updateStoryLikeStatus(storyID: story.id, liked: liked))
            try await persistenceService.persistStoryData(data)
        } catch {
            liked.toggle() // rollback state
            let data = StoryPersistedData(userId: story.userId, liked: liked)
            try? await persistenceService.persistStoryData(data)
            // TODO: Error Logging
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
