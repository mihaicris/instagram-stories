import Dependencies
import Kingfisher
import Persistence
import SwiftUI
import UIComponents

struct StoryScreen: View {
    @Environment(\.dismiss) var dismiss

    let model: StoryScreenModel

    var body: some View {
        VStack(spacing: 14) {
            MediaView(segment: model.currentSegment) {
                model.onContentTap(x: $0, width: $1)
            }

            HStack(spacing: 12) {
                MesssageInputButtonView(action: {})

                HeartButtonView(
                    action: { Task { await model.onLike() } },
                    liked: model.liked,
                    unread: false
                )
                .tint(model.liked ? .red : .white)
                .frame(height: 20)

                MessagesButtonView(action: {})
                    .tint(.white)
                    .frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.black)
        .overlay(alignment: .top) {
            VStack(spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(0..<model.progressBars.count, id: \.self) { index in
                        Capsule().fill(.white)
                            .opacity(0.3)
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .leading) {
                                GeometryReader { proxy in
                                    let width = proxy.size.width * model.progressBars[index]
                                    Capsule()
                                        .fill(.white)
                                        .frame(width: width)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                    }
                }

                //                StoryDetailsView(
                //                    userProfileURL: model.userProfileImageURL,
                //                    username: model.username,
                //                    activeTime: model.activeTime,
                //                    musicInfo: model.segments[currentSegmentIndex].musicInfo
                //                )
            }
            .padding(8)
        }
    }

    struct MediaView: View {
        let segment: StoryScreenModel.Segment
        let onTap: (_ x: CGFloat, _ width: CGFloat) -> Void

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    switch segment.type {
                    case "image":
                        KFImage(segment.url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)

                    //                    case "video":
                    //                        VideoPlayerView(url: segment.url, progress: $currentSegmentProgress)
                    //                            .id(segment.id)

                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            onTap(value.location.x, geometry.size.width)
                        }
                )
            }
        }
    }

    struct MesssageInputButtonView: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text("Send message...")
                    .font(.system(size: 16)).bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay {
                        Capsule()
                            .stroke(.white, lineWidth: 0.3)
                            .padding(2)
                    }
            }
        }
    }
}

// swiftlint:disable force_unwrapping
// swiftlint:disable line_length
#Preview {
    prepareDependencies {
        $0.apiService = APIServiceProvidingLocalData()
        $0.persistenceService = PersistenceServiceUserDefaults()
    }

    return StoryScreen(
        model: StoryScreenModel(
            dto: StoryScreenModel.DTO(
                story: .init(
                    id: 1,
                    userId: 1,
                    content: [
                        //                        .init(
                        //                            id: 0,
                        //                            type: "video",
                        //                            url: URL(string: "https://videos.pexels.com/video-files/5532765/5532765-uhd_1440_2732_25fps.mp4")!
                        //                        ),
                        .init(
                            id: 1,
                            type: "image",
                            url: URL(string: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d")!
                        )
                    ],
                    seen: false,
                    liked: false
                ),
                user: .init(
                    id: 1,
                    name: "Seraph",
                    profilePictureURL: "https://i.pravatar.cc/300?u=11"
                )
            )
        )
    )
}
