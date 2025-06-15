import AVFoundation

actor PlayersPool {
    private final class Item {
        let index: Int
        let player: AVPlayer
        let playerItem: AVPlayerItem

        init(index: Int, url: URL) {
            self.index = index
            self.playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
        }

        deinit {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }

        func prepareForReuse() {
            player.pause()
            player.seek(to: .zero)
        }
    }

    private var items: [Item] = []
    private let maxCount: Int
    private var currentIndex: Int?

    init(maxCount: Int) {
        self.maxCount = maxCount
    }

    func add(index: Int, url: URL) -> AVPlayer {
        currentIndex = index

        if let existing = items.first(where: { $0.index == index }) {
            existing.prepareForReuse()
            return existing.player
        }

        let newItem = Item(index: index, url: url)
        items.append(newItem)

        if items.count > maxCount {
            evictFarthest()
        }

        return newItem.player
    }

    private func evictFarthest() {
        guard let currentID = currentIndex else { return }
        guard
            let farthest = items.max(by: {
                abs($0.index - currentID) < abs($1.index - currentID)
            })
        else { return }

        items.removeAll { $0.index == farthest.index }
    }

    func debugCurrentPlayers() {
        let ids = items.map(\.index).sorted()
        print("Current players: \(ids)")
    }

    func releaseAll() {
        items.removeAll()
        debugCurrentPlayers()
    }
}
