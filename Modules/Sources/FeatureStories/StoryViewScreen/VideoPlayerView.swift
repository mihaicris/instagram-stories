import AVFoundation
import SwiftUI

struct VideoPlayerView: View {
    let player: AVPlayer

    var body: some View {
        CustomVideoPlayerView(player: player)  // Nested for expand to margins of container
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
