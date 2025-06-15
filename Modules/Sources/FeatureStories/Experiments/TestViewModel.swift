// swiftlint:disable force_unwrapping

import AVFoundation
import Observation
import SwiftUI

@MainActor
@Observable
public final class TestViewModel {
    struct Content: Identifiable {
        let id: Int
        let player: AVPlayer
        let observer: PlayerObserver
    }

    struct Segment {
        let segmentID: String
        let url: URL
    }

    var content: Content?
    var progress: Double = 0.0

    @ObservationIgnored
    var currentIndex: Int = 0

    private let playersPool = PlayersPool(maxCount: 3)
    private let preloadDistance = 1

    let segments: [Segment] = [
        Segment(
            segmentID: "A",
            url: URL(string: "https://videos.pexels.com/video-files/32488204/13853910_1080_1920_25fps.mp4")!
        ),
        Segment(
            segmentID: "B",
            url: URL(string: "https://videos.pexels.com/video-files/5532771/5532771-uhd_1440_2732_25fps.mp4")!
        ),
        Segment(
            segmentID: "C",
            url: URL(string: "https://videos.pexels.com/video-files/32426802/13830960_1080_1920_30fps.mp4")!
        ),
        Segment(
            segmentID: "D",
            url: URL(string: "https://videos.pexels.com/video-files/32415027/13827220_1440_2560_60fps.mp4")!
        ),
        Segment(
            segmentID: "E",
            url: URL(string: "https://videos.pexels.com/video-files/32144507/13705434_1440_2560_30fps.mp4")!
        ),
    ]

    public init() {}

    func onAppear() async {
        await move(to: currentIndex)
    }

    func previous() async {
        guard currentIndex > 0 else { return }
        await move(to: currentIndex - 1)
    }
    func next() async {
        guard currentIndex < segments.count - 1 else { return }
        await move(to: currentIndex + 1)
    }

    private func move(to index: Int) async {
        content?.player.pause()
        currentIndex = index

        let segment = segments[currentIndex]

        let player = await playersPool.add(index: index, url: segment.url)

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

        content = Content(id: index, player: player, observer: observer)
        player.play()

        await preload()
        await playersPool.debugCurrentPlayers()
    }

    private func preload() async {
        func preloadIfValid(_ index: Int) async {
            guard segments.indices.contains(index) else { return }
            _ = await playersPool.add(index: index, url: segments[index].url)
        }

        for offset in 1...preloadDistance {
            await preloadIfValid(currentIndex - offset)
            await preloadIfValid(currentIndex + offset)
        }
    }
}
