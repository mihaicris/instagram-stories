import AVFoundation

final class PoolItem {
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
