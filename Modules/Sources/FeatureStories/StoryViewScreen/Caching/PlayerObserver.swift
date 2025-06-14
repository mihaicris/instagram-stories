import AVFoundation

final class PlayerObserver {
    private var statusObservation: NSKeyValueObservation?
    private var keepUpObservation: NSKeyValueObservation?
    private var stalledObserver: NSObjectProtocol?
    private var endObserver: NSObjectProtocol?
    private var timeObserverToken: Any?

    init(player: AVPlayer, onVideoEnd: @Sendable @escaping () -> Void, onProgressUpdate: @Sendable @escaping (Double) -> Void) {
        guard let item = player.currentItem else { return }

        statusObservation = item.observe(\.status, options: [.new]) { item, _ in
            if item.status == .failed {
                print("Player failed: \(item.error?.localizedDescription ?? "Unknown error")")
            }
        }

        keepUpObservation = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { item, _ in
            if item.isPlaybackLikelyToKeepUp {
                print("Buffering finished, resuming playback.")
                player.play()
            } else {
                print("Buffering...")
                player.pause()
            }
        }

        stalledObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemPlaybackStalled,
            object: item,
            queue: .main
        ) { _ in
            print("Playback stalled. Trying to resume...")
            player.play()
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) {_ in
            print("Video ended.")
            onVideoEnd()
        }

        // Progress observer every 0.5 seconds
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600),
            queue: .main
        ) { [weak player] time in
            guard
                let player,
                let currentItem = player.currentItem
            else {
                return
            }
            let duration = currentItem.duration.seconds
            guard duration > 0 else { return }
            let progress = time.seconds / duration
            onProgressUpdate(progress)
        }
    }

    deinit {
        statusObservation?.invalidate()
        keepUpObservation?.invalidate()
        if let observer = stalledObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let token = timeObserverToken {
            // player reference is weak, so no crash if player is deallocated
            // but normally you should keep a strong reference to player to remove observer
        }
    }
}
