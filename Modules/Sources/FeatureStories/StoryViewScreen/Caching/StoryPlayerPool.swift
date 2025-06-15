import AVFoundation
import Foundation

actor StoryPlayerPool {
    private class PoolItem {
        let segmentID: Int
        let player: AVPlayer
        let playerItem: AVPlayerItem

        init(segmentID: Int, url: URL) {
            self.segmentID = segmentID
            self.playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
        }
        
        deinit {
            stopAndCleanup()
        }

        func prepareForReuse() {
            player.pause()
            player.seek(to: .zero)
        }

        func stopAndCleanup() {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
    }

    private var pool: [PoolItem] = []
    private let maxCount: Int
    private var currentSegmentID: Int?

    init(maxCount: Int) {
        self.maxCount = maxCount
    }

    func add(segmentID: Int, url: URL) -> AVPlayer {
        currentSegmentID = segmentID

        if let existing = pool.first(where: { $0.segmentID == segmentID }) {
            existing.prepareForReuse()
            return existing.player
        }

        let newItem = PoolItem(segmentID: segmentID, url: url)
        pool.append(newItem)

        if pool.count > maxCount {
            evictFarthest()
        }

        return newItem.player
    }

    private func evictFarthest() {
        guard let currentID = currentSegmentID else { return }
        guard let farthest = pool.max(by: {
            abs($0.segmentID - currentID) < abs($1.segmentID - currentID)
        }) else { return }

        pool.removeAll { $0.segmentID == farthest.segmentID }
    }

    func debugCurrentPlayers() {
        let ids = pool.map(\.segmentID).sorted()
        print("Current players: \(ids)")
    }

    func releaseAll() {
        pool.removeAll()
    }
}
