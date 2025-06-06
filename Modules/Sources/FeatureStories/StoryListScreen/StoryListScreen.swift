import Dependencies
import Kingfisher
import SwiftUI
import UIComponents

public struct StoryListScreen: View {
    @Bindable var model: StoryListScreenModel

    public init(model: StoryListScreenModel) {
        self.model = model
    }

    public var body: some View {
        switch model.state {
        case .data(let items):
            StoryItemsView(items: items)
                .environment(\.isLoadingMore, model.isLoadingMore)
                .fullScreenCover(item: $model.navigationToStory) { dto in
                    StoryViewScreen(model: StoryViewScreenModel(
                        dto: dto,
                        onSeen: {
                            model.refresh(userId: dto.user.id)
                        }
                    ))
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

    struct StoryItemsView: View {
        let items: [StoryItemViewModel]

        var body: some View {
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    HeadingView(action: {})

                    Spacer()

                    HeartButtonView(action: {}, liked: false, unread: true)
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
            @Environment(\.isLoadingMore)
            private var isLoadingMore

            let items: [StoryItemViewModel]
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
                let item: StoryItemViewModel
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
                                StoryStatusView(seen: item.seen, metric: metric)
                            }

                        Text(item.username)
                            .font(.caption)
                            .truncationMode(.tail)
                    }
                    .padding(metric * 0.05)
                }
            }

            struct StoryStatusView: View {
                let seen: Bool
                let metric: CGFloat

                var body: some View {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: seen ? [.gray] : [.red, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: metric * 0.03
                        )
                }
            }
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

#Preview {
    prepareDependencies { $0.apiService = FakeAPIService() }
    return StoryListScreen(model: StoryListScreenModel())
}
