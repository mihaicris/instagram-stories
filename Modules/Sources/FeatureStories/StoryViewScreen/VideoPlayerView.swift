import AVKit
import SwiftUI

struct VideoPlayerView: View {
    let url: URL
    @Binding var progress: Double

    @State private var player: AVPlayer
    @State private var endReached = false
    @State private var timeObserverToken: Any?
    @State private var endTimeObserver: Any?

    init(url: URL, progress: Binding<Double>) {
        self.url = url
        self._progress = progress
        self._player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        CustomVideoPlayerView(player: player)
            .onAppear {
                progress = 0
                player.play()
                addObservers()
            }
            .onDisappear {
                player.pause()
                removeObservers()
            }
    }

    private func addObservers() {
        addEndObserver()

        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [player] time in
            Task { @MainActor in
                withAnimation {
                    guard let duration = player.currentItem?.duration.seconds,
                        duration > 0
                    else {
                        return
                    }
                    progress = time.seconds / duration
                }
            }
        }
    }

    private func removeObservers() {
        removeEndObserver()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    private func addEndObserver() {
        endTimeObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            Task { @MainActor in
                endReached = true
            }
        }
    }

    private func removeEndObserver() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    private struct CustomVideoPlayerView: UIViewRepresentable {
        let player: AVPlayer

        func makeUIView(context _: Context) -> PlayerView {
            let view = PlayerView()
            view.player = player
            return view
        }

        func updateUIView(_: PlayerView, context _: Context) {}

        class PlayerView: UIView {
            override class var layerClass: AnyClass {
                AVPlayerLayer.self
            }

            var playerLayer: AVPlayerLayer {
                // swiftlint:disable:next force_cast
                layer as! AVPlayerLayer
            }

            var player: AVPlayer? {
                get { playerLayer.player }
                set {
                    playerLayer.player = newValue
                    playerLayer.videoGravity = .resizeAspectFill
                }
            }
        }
    }
}
