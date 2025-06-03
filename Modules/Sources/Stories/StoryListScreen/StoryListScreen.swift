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
            StoryItemsView(
                items: items,
                isLoadingMore: model.isLoadingMore
            )
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

struct StoryItemsView: View {
    let items: [UserItemViewModel]
    let isLoadingMore: Bool
    
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
            
            ItemListView(
                items: items,
                isLoadingMore: isLoadingMore
            )
            
            Spacer()
        }
    }
    
    struct HeadingView: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("For You")
                        .font(.system(size: 20,weight: .heavy))
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
            }
            .tint(.black)
        }
    }

    struct ItemListView: View {
        let items: [UserItemViewModel]
        let isLoadingMore: Bool

        
        private let itemSize: CGFloat = 90

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        Button(action: item.onTap) {
                            VStack {
                                KFImage(item.imageURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: itemSize, height: itemSize)
                                    .clipShape(Circle())
                                    .padding(itemSize * 0.04)
                                    .overlay {
                                        if !item.seen {
                                            UnreadStoryMarkerView(lineWidth: itemSize * 0.03)
                                        }
                                    }
                                
                                Text(item.body)
                                    .font(.caption)
                                    .truncationMode(.tail)
                                    
                            }
                            .padding(itemSize * 0.05)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .tint(.black)
                        .frame(maxWidth: itemSize * 1.3)
                        .onAppear {
                            Task {
                                if index == items.count - 3 {
                                    await item.onAppear()
                                }
                            }
                        }
                    }
                    if isLoadingMore {
                        ProgressView()
                            .padding(.horizontal)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
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

import  Dependencies
#Preview {
    let _ = prepareDependencies { $0.apiService = FakeAPIService() }
    StoryListScreen(model: StoryListScreenModel())
}
