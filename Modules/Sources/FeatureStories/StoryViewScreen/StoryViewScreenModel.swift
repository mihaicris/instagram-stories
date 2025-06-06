import Dependencies
import Foundation
import Networking
import Observation
import Persistence

@MainActor
@Observable
final class StoryViewScreenModel {
    struct DTO: Identifiable {
        let story: Story
        let user: User

        var id: Int { user.id }
    }

    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    @ObservationIgnored
    @Dependency(\.persistenceService) private var persistenceService

    @ObservationIgnored
    private let dto: DTO

    var liked: Bool = false

    let userProfileImageURL: URL
    let username: String
    let userVerified: Bool
    let activeTime: String
    let segments: [Segment]

    init(dto: DTO) {
        self.dto = dto
        self.userProfileImageURL = URL(string: dto.user.profilePictureURL) ?? URL(string: "https://i.pravatar.cc/300?u=11")!  // TODO: default
        self.username = dto.user.name
        self.userVerified = Bool.random()
        self.activeTime = "\((1...8).randomElement() ?? 1)h"
        self.segments = dto.story.content.map({ media in
            Segment(url: media.url, type: media.type, musicInfo: "Melody")
        })
        self.liked = dto.story.liked
    }

    func onClose() {
    }

    func onLike() async {
        liked.toggle()
        do {
            let data = StoryPersistedData(userId: dto.story.userId, liked: liked)
            try await apiService.request(.updateStoryLikeStatus(storyID: dto.story.id, liked: liked))
            try await persistenceService.persistStoryData(data)
        } catch {
            liked.toggle()  // rollback state
            let data = StoryPersistedData(userId: dto.story.userId, liked: liked)
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
