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
    var seen: Bool = false

    let userProfileImageURL: URL
    let username: String
    let userVerified: Bool
    let activeTime: String
    let segments: [Segment]

    init(dto: DTO) {
        self.dto = dto
        self.userProfileImageURL = URL(string: dto.user.profilePictureURL) ?? URL.temporaryDirectory
        self.username = dto.user.name
        self.userVerified = Bool.random()
        self.activeTime = "\((1...8).randomElement() ?? 1)h"
        self.segments = dto.story.content.map({ media in
            Segment(id: media.id, url: media.url, type: media.type, musicInfo: "Melody")
        })
        self.liked = dto.story.liked
        self.seen = dto.story.seen
    }

    func onClose() {
    }

    func onLike() async {
        do {
            liked.toggle()
            let data = StoryData(userId: dto.story.userId, liked: liked, seen: seen)
            try await apiService.request(.updateStoryLikeStatus(storyID: dto.story.id, liked: liked))
            try await persistenceService.persistStoryData(data)
        } catch {
            liked.toggle()  // rollback state
            let data = StoryData(userId: dto.story.userId, liked: liked, seen: seen)
            try? await persistenceService.persistStoryData(data)
            logger.error("Couldn't like/unlike the story: \(error.localizedDescription, privacy: .public)")
        }
    }

    func markAsSeen() async {
        do {
            let data = StoryData(userId: dto.story.userId, liked: liked, seen: true)
            try await persistenceService.persistStoryData(data)
        } catch {
            logger.error("Couldn't mark story as unseen: \(error.localizedDescription, privacy: .public)")
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

    struct Segment: Identifiable {
        let id: Int
        let url: URL
        let type: String
        let musicInfo: String?
    }
}
