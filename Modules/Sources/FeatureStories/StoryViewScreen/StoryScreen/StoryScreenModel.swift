import AVFoundation
import Dependencies
import Foundation
import Observation
import Persistence

@MainActor
@Observable
final class StoryScreenModel {
    var segmentsCount: Int

    var currentSegment: Segment
    var currentSegmentIndex: Int = 0
    var currentSegmentProgress: Double = 0.0
    
    var progressBars: [Double] = []
    var liked: Bool = false
    var seen: Bool = false

    @ObservationIgnored
    private var segments: [Segment] = []
    
    @ObservationIgnored
    private let dto: DTO
    
    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    @ObservationIgnored
    @Dependency(\.persistenceService) private var persistenceService

    init(dto: DTO) {
        self.dto = dto
        self.segmentsCount = dto.story.content.count
        self.segments = dto.story.content.map { media in
            Segment(
                id: media.id,
                url: media.url,
                type: media.type,
                musicInfo: "Melody" // TODO: Fix hardcoded string
            )
        }
        self.currentSegment = self.segments.first!  // swiftlint:disable:this force_unwrapping
        self.progressBars = [Double](repeating: 0.5, count: self.segmentsCount)
    }

    func onContentTap(x: CGFloat, width: CGFloat) {
        print(x, width)
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

    struct DTO: Identifiable {
        let story: Story
        let user: User

        var id: Int { user.id }
    }

    struct Segment: Identifiable {
        let id: Int
        let url: URL
        let type: String
        let musicInfo: String?
    }
}
