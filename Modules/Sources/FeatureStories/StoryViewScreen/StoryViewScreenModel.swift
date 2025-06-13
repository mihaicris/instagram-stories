import AVFoundation
import Dependencies
import Foundation
import Observation
import Persistence

@MainActor
@Observable
final class StoryViewScreenModel {
    var currentSegment: Segment

    var progressBars: [Double] = []
    var liked: Bool = false
    var seen: Bool = false
    var shouldDismiss = false
    let userProfileImageURL: URL
    let username: String
    let userVerified: Bool
    let activeTime: String

    @ObservationIgnored @Dependency(\.apiService) private var apiService
    @ObservationIgnored @Dependency(\.persistenceService) private var persistenceService

    @ObservationIgnored private var segments: [Segment] = []
    @ObservationIgnored private let dto: DTO
    @ObservationIgnored private var segmentsCount: Int

    @ObservationIgnored private var currentSegmentIndex: Int = 0

    @ObservationIgnored private var startTime = Date()
    @ObservationIgnored private var progressTask: Task<Void, Never>?
    @ObservationIgnored private let duration: TimeInterval = 3.0
    @ObservationIgnored private let interval: TimeInterval = 0.1
    @ObservationIgnored private var timeObserverToken: Any?
    @ObservationIgnored private var endTimeObserver: Any?

    init(dto: DTO) {
        self.dto = dto
        self.userProfileImageURL = URL(string: dto.user.profilePictureURL) ?? URL.temporaryDirectory
        self.username = dto.user.name
        self.userVerified = Bool.random()
        self.activeTime = "\((1...8).randomElement() ?? 1)h"
        self.segmentsCount = dto.story.content.count
        self.segments = dto.story.content.map { media in
            switch media.type {
            case "image":
                return .init(id: media.id, type: .image(media.url), musicInfo: "Melody")

            case "video":
                return .init(id: media.id, type: .video(AVPlayer(url: media.url)), musicInfo: "Melody")

            default:
                return .init(id: 0, type: .image(.temporaryDirectory), musicInfo: nil)
            }
        }
        self.currentSegment = self.segments.first!  // swiftlint:disable:this force_unwrapping
        self.progressBars = [Double](repeating: 0.0, count: self.segmentsCount)
    }

    func onRegionTap(x: CGFloat, width: CGFloat) {
        if x > width / 2 {
            gotoNextSegment()
        } else {
            goToPreviousSegment()
        }
    }

    func onAppear() {
        startTimer()
    }

    func onDissapear() {
        stopTimer()
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
        let type: MediaType
        let musicInfo: String?

        enum MediaType {
            case image(URL)
            case video(AVPlayer)
        }
    }

    // MARK: - Private methods

    private func updateProgressForCurrentSegment(_ progress: Double) {
        progressBars = (0..<segmentsCount).map { index in
            if index < currentSegmentIndex {
                return 1.0
            }
            if index == currentSegmentIndex {
                return progress
            }
            return 0.0
        }

        if progress == 1.0 {
            if currentSegmentIndex < segmentsCount - 1 {
                gotoNextSegment()
            } else {
                Task {
                    await markAsSeen()
                    shouldDismiss = true
                }
            }
        }
    }

    private func startTimer() {
        switch currentSegment.type {
        case .image:
            startDefaultProgressTimer()

        case .video(let player):
            startMovieProgressTimer(player: player)
        }
    }

    private func stopTimer() {
        switch currentSegment.type {
        case .image:
            stopDefaultProgressTimer()

        case .video(let player):
            stopMovieProgressTimer(player: player)
        }
    }

    private func gotoNextSegment() {
        stopTimer()
        currentSegmentIndex += (currentSegmentIndex < segmentsCount - 1) ? 1 : 0
        currentSegment = segments[currentSegmentIndex]
        startTimer()
    }

    private func goToPreviousSegment() {
        stopTimer()
        currentSegmentIndex -= (currentSegmentIndex > 0) ? 1 : 0
        currentSegment = segments[currentSegmentIndex]
        startTimer()
    }

    private func startDefaultProgressTimer() {
        startTime = Date()

        progressTask = Task {
            let startTime = Date()

            while !Task.isCancelled {
                let elapsed = startTime.timeIntervalSinceNow * -1

                await MainActor.run {
                    updateProgressForCurrentSegment(elapsed >= duration ? 1.0 : elapsed / duration)
                }

                if elapsed >= duration {
                    stopDefaultProgressTimer()
                }

                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    private func stopDefaultProgressTimer() {
        progressTask?.cancel()
        progressTask = nil
    }

    private func startMovieProgressTimer(player: AVPlayer) {
        endTimeObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            Task { @MainActor [weak self] in
                self?.stopMovieProgressTimer(player: player)
            }
        }

        let interval = CMTime(seconds: interval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [player] time in
            Task { @MainActor [weak self] in
                guard let self, let duration = player.currentItem?.duration.seconds, duration > 0 else {
                    return
                }
                updateProgressForCurrentSegment(time.seconds / duration)
            }
        }
        player.play()
    }

    private func stopMovieProgressTimer(player: AVPlayer) {
        player.pause()
        player.seek(to: .zero)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
}
