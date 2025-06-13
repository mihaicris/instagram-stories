import AVFoundation
import SwiftUI

struct VideoPlayerNewView: View {
    let player: AVPlayer

    @State private var endReached = false
    @State private var timeObserverToken: Any?
    @State private var endTimeObserver: Any?

    var body: some View {
        CustomVideoPlayerView(player: player)
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
