import Dependencies
import Kingfisher
import SwiftUI
import UIComponents

public struct StoryListScreen: View {
    public init(model: StoryListScreenModel) {
        self.model = model
    }

    @Bindable var model: StoryListScreenModel

    public var body: some View {
        switch model.state {
        case .data(let items):
            StoryItemsView(items: items)
                .environment(\.isLoadingMore, model.isLoadingMore)
                .fullScreenCover(item: $model.presentedStory) {
                    StoryViewScreen(model: .init(story: $0))
                }

        case .empty:
            Text("Empty Stance / in progress")

        case .error(let message):
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()

        case .loading:
            ProgressView()
                .onAppear { Task { await model.onAppear() } }
        }
    }
}

extension EnvironmentValues {
    private struct IsLoadingMoreKey: EnvironmentKey {
        static let defaultValue: Bool = false
    }

    fileprivate var isLoadingMore: Bool {
        get { self[IsLoadingMoreKey.self] }
        set { self[IsLoadingMoreKey.self] = newValue }
    }
}

struct StoryItemsView: View {
    let items: [UserItemViewModel]

    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                HeadingView(action: {})

                Spacer()

                HeartButtonView(action: {}, unread: true)
                    .tint(.black)

                MessagesButtonView(action: {})
                    .tint(.black)
            }
            .padding(.horizontal)

            ItemListView(items: items)

            Spacer()
        }
    }

    struct HeadingView: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("For You")
                        .font(.system(size: 20, weight: .heavy))

                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
            }
            .tint(.black)
        }
    }

    struct ItemListView: View {
        @Environment(\.isLoadingMore) private var isLoadingMore
        let items: [UserItemViewModel]
        private let metric: CGFloat = 90

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        Button(
                            action: {
                                Task { await item.onTap() }
                            },
                            label: {
                                ItemView(item: item, metric: metric)
                            }
                        )
                        .buttonStyle(PlainButtonStyle())
                        .tint(.black)
                        .frame(maxWidth: metric * 1.3)
                        .onAppear {
                            Task {
                                if index == items.count - 3 {
                                    await item.onAppear()
                                }
                            }
                        }
                    }
                    if isLoadingMore {
                        ProgressView().padding(.horizontal)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            }
        }

        struct ItemView: View {
            let item: UserItemViewModel
            let metric: CGFloat

            var body: some View {
                VStack {
                    KFImage(item.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: metric, height: metric)
                        .clipShape(Circle())
                        .padding(metric * 0.04)
                        .overlay {
                            if !item.seen {
                                UnreadStoryMarkerView(lineWidth: metric * 0.03)
                            }
                        }

                    Text(item.body)
                        .font(.caption)
                        .truncationMode(.tail)
                }
                .padding(metric * 0.05)
            }
        }

        struct UnreadStoryMarkerView: View {
            let lineWidth: CGFloat

            var body: some View {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.red, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: lineWidth
                    )
            }
        }
    }
}

#Preview {
    prepareDependencies { $0.apiService = FakeAPIService() }
    return StoryListScreen(model: StoryListScreenModel())
}
