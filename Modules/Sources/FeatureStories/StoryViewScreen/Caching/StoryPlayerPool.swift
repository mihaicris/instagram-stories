import AVFoundation
import Foundation

actor StoryPlayerPool {
    private struct PoolItem {
        let segmentID: Int
        let playerWrapper: PooledPlayer
    }

    private var pool: [PoolItem] = []
    private let maxCount = 3
    private var currentSegmentID: Int?

    func add(segmentID: Int, url: URL) -> AVPlayer {
        currentSegmentID = segmentID

        if let existing = pool.first(where: { $0.segmentID == segmentID }) {
            existing.playerWrapper.prepareForReuse()
            return existing.playerWrapper.player
        }

        let pooledPlayer = PooledPlayer(url: url)
        let newItem = PoolItem(segmentID: segmentID, playerWrapper: pooledPlayer)
        pool.append(newItem)

        if pool.count > maxCount {
            evictFarthest()
        }

        return newItem.playerWrapper.player
    }

    private func evictFarthest() {
        guard let currentID = currentSegmentID else { return }
        guard let farthest = pool.max(by: { abs($0.segmentID - currentID) < abs($1.segmentID - currentID) }) else { return }

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
