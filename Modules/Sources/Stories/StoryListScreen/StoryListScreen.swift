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
                .fullScreenCover(item: $model.presentedStory) {
                    StoryViewScreen(model: .init(story: $0))
                }

        case .empty:
            Text("Empty Stance / in progress")

        case .error(let message):
            Text(message)

        case .loading:
            ProgressView()
                .onAppear { Task { await model.onAppear() } }
        }
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
        
        private let itemSize: CGFloat = 90

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(items) { item in
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

#Preview {
    StoryListScreen(model: StoryListScreenModel())
}
