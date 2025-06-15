import AVFoundation
import Foundation

actor StoryPlayerPool {
    private class PoolItem {
        let index: Int
        let player: AVPlayer
        let playerItem: AVPlayerItem

        init(index: Int, url: URL) {
            self.index = index
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
    private var currentIndex: Int?

    init(maxCount: Int) {
        self.maxCount = maxCount
    }

    func add(index: Int, url: URL) -> AVPlayer {
        currentIndex = index

        if let existing = pool.first(where: { $0.index == index }) {
            existing.prepareForReuse()
            return existing.player
        }

        let newItem = PoolItem(index: index, url: url)
        pool.append(newItem)

        if pool.count > maxCount {
            evictFarthest()
        }

        return newItem.player
    }

    private func evictFarthest() {
        guard let currentID = currentIndex else { return }
        guard let farthest = pool.max(by: {
            abs($0.index - currentID) < abs($1.index - currentID)
        }) else { return }

        pool.removeAll { $0.index == farthest.index }
    }

    func debugCurrentPlayers() {
        let ids = pool.map(\.index).sorted()
        print("Current players: \(ids)")
    }

    func releaseAll() {
        pool.removeAll()
    }
}
