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
                logger.info("Player failed: \(item.error?.localizedDescription ?? "Unknown error", privacy: .public)")
            }
        }

        keepUpObservation = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { item, _ in
            if item.isPlaybackLikelyToKeepUp {
                logger.info("Buffering finished, resuming playback.")
                player.play()
            } else {
                logger.info("Buffering...")
                player.pause()
            }
        }

        stalledObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemPlaybackStalled,
            object: item,
            queue: .main
        ) { _ in
            logger.info("Playback stalled. Trying to resume...")
            player.play()
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            logger.info("Video ended.")
            onVideoEnd()
            onProgressUpdate(0.0)
        }

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
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
    }
}
