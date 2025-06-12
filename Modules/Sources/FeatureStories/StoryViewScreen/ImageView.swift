import Kingfisher
import SwiftUI

struct ImageView: View {
    let url: URL

    @Binding var progress: Double
    @State private var timer: Timer?
    @State private var startTime: Date?

    private let duration: TimeInterval = 5.0
    private let interval: TimeInterval = 0.1

    init(url: URL, progress: Binding<Double>) {
        self.url = url
        self._progress = progress
    }

    var body: some View {
        KFImage(url)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .onAppear {
                startProgressTimer()
            }
            .onDisappear {
                stopProgressTimer()
            }
    }

    private func startProgressTimer() {
        startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [startTime] _ in
            guard let startTime else {
                return
            }
            let elapsed = Date().timeIntervalSince(startTime)
            Task { @MainActor in
                withAnimation {
                    if elapsed >= duration {
                        stopProgressTimer()
                        progress = 1
                    } else {
                        progress = elapsed / duration
                    }
                }
            }
        }
    }

    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }
}
