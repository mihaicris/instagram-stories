import AVFoundation
import Dependencies
import Foundation
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

    struct SegmentViewModel: Identifiable {
        let id: Int
        let model: Model
        let enhancement: Enhancement?

        func stop() {
            switch model {
            case .image(_, let observer):
                observer.stopTimer()
                
            case .video(let player, _):
                player.pause()
                player.seek(to: .zero)
            }
        }

        enum Model {
            case image(URL, ImageObserver)
            case video(AVPlayer, PlayerObserver)
        }

        struct Enhancement {
            let artist: String
            let song: String
        }
    }

    var liked: Bool
    var seen: Bool
    var progress: Double = 0.0
    var segmentViewModel: SegmentViewModel?
    var shouldDismiss = false
    let storyID: Int
    let userID: Int
    let userProfileImageURL: URL
    let username: String
    let userVerified: Bool
    let activeTime: String

    private let media: [Story.Media]
    private let playersPool = PlayersPool(maxCount: 3)
    private let preloadDistance = 1

    @ObservationIgnored @Dependency(\.apiService) private var apiService
    @ObservationIgnored @Dependency(\.persistenceService) private var persistenceService
    @ObservationIgnored let segmentCount: Int
    @ObservationIgnored var currentIndex: Int = 0

    init(dto: DTO) {
        self.userID = dto.user.id
        self.storyID = dto.story.id
        self.media = dto.story.content
        self.segmentCount = self.media.count
        self.liked = dto.story.liked
        self.seen = dto.story.seen

        /// TODO: Provide fallback user profile picture URL
        self.userProfileImageURL =
            URL(string: dto.user.profilePictureURL)
            ?? .userDirectory

        self.username = dto.user.name
        self.userVerified = Bool.random()

        /// TODO: Include user verified status in User model
        self.activeTime = "\((1...8).randomElement() ?? 1)h"/// TODO: Include user active time in User model
    }

    func onAppear() async {
        await move(to: currentIndex)
    }

    func onClose() async {
        await closeScreen()
    }

    func onLike() async {
        do {
            liked.toggle()
            let data = StoryData(userID: userID, liked: liked, seen: seen)
            try await apiService.request(.updateStoryLikeStatus(storyID: storyID, liked: liked))
            try await persistenceService.persistStoryData(data)
        } catch {
            liked.toggle()  // rollback state
            let data = StoryData(userID: userID, liked: liked, seen: seen)
            try? await persistenceService.persistStoryData(data)
            logger.error("Couldn't like/unlike the story: \(error.localizedDescription, privacy: .public)")
        }
    }

    func onRegionTap(x: CGFloat, width: CGFloat) async {
        if x > width / 2 {
            await next()
        } else {
            await previous()
        }
    }

    // MARK: - Helpers

    private var isFirstSegment: Bool {
        currentIndex == 0
    }

    private var isLastSegment: Bool {
        currentIndex == media.count - 1
    }

    private func closeScreen() async {
        await playersPool.releaseAll()
        shouldDismiss = true
    }

    private func previous() async {
        if isFirstSegment {
            await closeScreen()
        } else {
            await move(to: currentIndex - 1)
        }
    }

    private func next() async {
        if isLastSegment {
            segmentViewModel?.stop()
            await markAsSeen()
            await closeScreen()
        } else {
            await move(to: currentIndex + 1)
        }
    }

    private func move(to index: Int) async {
        segmentViewModel?.stop()

        currentIndex = index

        let content = media[currentIndex]

        let enhancement: SegmentViewModel.Enhancement? = {
            if let artist = content.band, let song = content.song {
                return .init(artist: artist, song: song)
            }
            return nil
        }()

        switch content.type {
        case "video":
            let player = await playersPool.add(index: index, url: content.url)

            let observer = PlayerObserver(
                player: player,
                onVideoEnd: { [weak self] in
                    Task {
                        await self?.next()
                    }
                },
                onProgressUpdate: { [weak self] progress in
                    MainActor.assumeIsolated {
                        self?.progress = progress
                    }
                }
            )
            segmentViewModel = SegmentViewModel(id: index, model: .video(player, observer), enhancement: enhancement)
            player.play()

        case "image":
            let observer = ImageObserver(
                onTimerEnd: {
                    Task { [weak self] in
                        await self?.next()
                    }
                },
                onProgressUpdate: { [weak self] progress in
                    MainActor.assumeIsolated {
                        self?.progress = progress
                    }
                }
            )
            segmentViewModel = SegmentViewModel(id: index, model: .image(content.url, observer), enhancement: enhancement)
            observer.starTimer()

        default:
            return
        }

        //        await preload()
        //        await playersPool.debugCurrentPlayers()
    }

    private func preload() async {
        func preloadIfValid(_ index: Int) async {
            guard media.indices.contains(index), media[index].type == "video" else { return }
            _ = await playersPool.add(index: index, url: media[index].url)
        }

        for offset in 1...preloadDistance {
            await preloadIfValid(currentIndex - offset)
            await preloadIfValid(currentIndex + offset)
        }
    }

    private func markAsSeen() async {
        do {
            let data = StoryData(userID: userID, liked: liked, seen: true)
            try await persistenceService.persistStoryData(data)
        } catch {
            logger.error("Couldn't mark story as unseen: \(error.localizedDescription, privacy: .public)")
        }
    }
}
