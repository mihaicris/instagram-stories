import SwiftUI

public struct TestView: View {
    let model: TestViewModel

    public init(model: TestViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            if let content = model.content {
                VideoPlayerView(player: content.player)
                    .id(content.id)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()

                ProgressView(value: model.progress)
                    .padding()

                HStack {
                    Button("Previous") {
                        Task { await model.previous() }
                    }
                    .padding()

                    Text(model.currentIndex.description).font(.headline.bold())

                    Button("Next") {
                        Task { await model.next() }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Task {
                await model.onAppear()
            }
        }
    }
}

#Preview {
    TestView(model: .init())
}
