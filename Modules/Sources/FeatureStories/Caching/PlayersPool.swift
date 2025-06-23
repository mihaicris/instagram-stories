import AVFoundation

actor PlayersPool {
    private var items: [PoolItem] = []
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

        let newItem = PoolItem(index: index, url: url)
        logger.info("🎦 🟢 Loaded VIDEO \(index, privacy: .public)")
        items.append(newItem)

        if items.count > maxCount {
            clearItem()
        }

        return newItem.player
    }

    private func clearItem() {
        guard let currentID = currentIndex else { return }
        guard
            let farthest = items.max(by: {
                abs($0.index - currentID) < abs($1.index - currentID)
            })
        else { return }

        items.removeAll { $0.index == farthest.index }
        logger.info("🎦 ⚪️ Cleared VIDEO \(farthest.index, privacy: .public)")
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
