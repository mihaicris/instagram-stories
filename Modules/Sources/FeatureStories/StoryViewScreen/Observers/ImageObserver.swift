import Foundation

final class ImageObserver {
    private let onTimerEnd: @Sendable () -> Void
    private let onProgressUpdate: @Sendable (Double) -> Void
    private let defaultTimerDuration: Double = 3.0
    private let intervalBetweenProgressUpdates: Double = 0.01
    private var timer: Timer?
    private var startTime: Date = .now

    init(
        onTimerEnd: @escaping @Sendable () -> Void,
        onProgressUpdate: @escaping @Sendable (Double) -> Void
    ) {
        self.onTimerEnd = onTimerEnd
        self.onProgressUpdate = onProgressUpdate
        self.startTime = Date()
    }

    func starTimer() {
        let startTime = self.startTime
        let defaultTimerDuration = self.defaultTimerDuration
        let onTimerEnd = self.onTimerEnd
        let onProgressUpdate = self.onProgressUpdate

        timer = Timer.scheduledTimer(withTimeInterval: intervalBetweenProgressUpdates, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)

            if elapsed >= defaultTimerDuration {
                onTimerEnd()
            } else {
                onProgressUpdate(elapsed / defaultTimerDuration)
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        onProgressUpdate(0.0)
    }

    deinit {
        stopTimer()
    }
}
