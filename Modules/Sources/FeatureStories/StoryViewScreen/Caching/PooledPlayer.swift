import AVFoundation

public final class PooledPlayer {
    public let player: AVPlayer
    private let playerItem: AVPlayerItem

    public init(url: URL) {
        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
    }
    
    deinit {
        stopAndCleanup()
    }

    public func prepareForReuse() {
        player.pause()
        player.seek(to: .zero)
    }

    public func stopAndCleanup() {
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}
