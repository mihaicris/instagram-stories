import Kingfisher
import SwiftUI
import UIComponents

// GESTURI
// -----------------------------------
// TODO: USER DETAILS IN STORY
// TODO: MOVE MOVE TIMERS IN VIEWMODEL
// TODO: SLIDE DOWN DISMISS IN ACCOUNT IMAGE
// TODO: ZOOM
// -----------------------------------

struct StoryViewScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset = CGSize.zero
    @State private var currentSegmentIndex: Int = 0
    @State private var currentSegmentProgress: Double = 0.0

    let model: StoryViewScreenModel

    var body: some View {
        ZStack {
            if dragOffset.height > 0 {
                Color.black.ignoresSafeArea()
            }

            VStack(spacing: 14) {
                MediaView(
                    segments: model.segments,
                    currentSegmentIndex: $currentSegmentIndex,
                    currentSegmentProgress: $currentSegmentProgress
                )
                .onChange(
                    of: currentSegmentProgress,
                    { _, newValue in
                        if newValue == 1 {
                            if currentSegmentIndex < model.segments.count - 1 {
                                currentSegmentIndex += 1
                            } else {
                                Task {
                                    await model.markAsSeen()
                                    dismiss()
                                }
                            }
                        }
                    }
                )
                #if false
                .overlay(alignment: .bottomTrailing) {
                    VStack(spacing: 0) {
                        Text("\(Int(currentSegmentProgress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                        Text("\(currentSegmentIndex + 1)/\(model.segments.count)")
                        .font(.caption)
                        .bold()
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(.white)
                        .overlay { Capsule().stroke(lineWidth: 0.3) }
                        .clipShape(Capsule())
                        .shadow(radius: 1.2)
                        .padding(6)
                    }
                }
                #endif

                HStack(spacing: 12) {
                    MesssageInputButtonView(action: {})

                    HeartButtonView(
                        action: {
                            Task {
                                await model.onLike()
                            }
                        },
                        liked: model.liked,
                        unread: false
                    )
                    .tint(model.liked ? .red : .white)
                    .frame(height: 18)

                    MessagesButtonView(action: {})
                        .tint(.white)
                        .frame(height: 18)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.black)
            .overlay(alignment: .top) {
                VStack(spacing: 6) {
                    HStack(spacing: 3) {
                        ForEach(0..<model.segments.count, id: \.self) { i in
                            Capsule().fill(.white)
                                .opacity(0.3)
                                .frame(height: 3)
                                .frame(maxWidth: .infinity)
                                .overlay(alignment: .leading) {
                                    GeometryReader { proxy in
                                        let progress = i < currentSegmentIndex ? 1 : (i == currentSegmentIndex ? currentSegmentProgress : 0)
                                        Capsule()
                                            .fill(.white)
                                            .frame(width: proxy.size.width * progress)
                                            .frame(maxHeight: .infinity)
                                    }
                                }
                        }
                    }

                    StoryDetailsView(
                        userProfileURL: model.userProfileImageURL,
                        username: model.username,
                        activeTime: model.activeTime,
                        musicInfo: model.segments[currentSegmentIndex].musicInfo
                    )
                }
                .padding(8)
            }
            //            .offset(y: dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 300 {
                            dismiss()
                        } else {
                            dragOffset = .zero
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {}
            )
        }
    }

    struct StoryDetailsView: View {
        @Environment(\.dismiss) private var dismiss

        let userProfileURL: URL
        let username: String
        let activeTime: String
        let musicInfo: String?

        var body: some View {
            HStack(spacing: 0) {
                KFImage(userProfileURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .padding(.trailing, 8)

                VStack(alignment: .leading) {
                    Text("\(username) ").bold()
                        + Text(activeTime)
                        .foregroundStyle(.white.opacity(0.8))
                    if let musicInfo {
                        HStack {
                            Image(systemName: "waveform")
                                .symbolEffect(.variableColor.dimInactiveLayers.cumulative.reversing)
                            Text("Kali Uchis ∙").bold() + Text(musicInfo)
                        }
                    }
                }
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)

                Spacer()

                // Story Options
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .imageScale(.medium)
                        .tint(.white)
                }
                .padding(12)
                .contentShape(Circle())

                // Story closing
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .tint(.white)
                }
                .padding(4)
                .contentShape(Circle())
            }
            .padding(.leading, 2)
            .frame(maxWidth: .infinity)
        }
    }

    struct MediaView: View {
        let segments: [StoryViewScreenModel.Segment]
        @Binding var currentSegmentIndex: Int
        @Binding var currentSegmentProgress: Double

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    switch segments[currentSegmentIndex].type {
                    case "image":
                        ImageView(url: segments[currentSegmentIndex].url, progress: $currentSegmentProgress)
                            .id(segments[currentSegmentIndex].id)

                    case "video":
                        VideoPlayerView(url: segments[currentSegmentIndex].url, progress: $currentSegmentProgress)
                            .id(segments[currentSegmentIndex].id)

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
                            let location = value.location
                            let halfWidth = geometry.size.width / 2

                            if location.x > halfWidth {
                                if currentSegmentIndex < segments.count - 1 {
                                    currentSegmentIndex += 1
                                }
                            } else {
                                currentSegmentIndex -= (currentSegmentIndex > 0 ? 1 : 0)
                            }
                        }
                )
                .onChange(of: currentSegmentIndex) { _, _ in
                    currentSegmentProgress = 0.0
                }
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
    StoryViewScreen(
        model: StoryViewScreenModel(
            dto: StoryViewScreenModel.DTO(
                story: .init(
                    id: 1,
                    userId: 1,
                    content: [
                        .init(
                            id: 0,
                            type: "image",
                            url: URL(
                                string:
                                    "https://images.pexels.com/photos/2280547/pexels-photo-2280547.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
                            )!
                        ),
                        .init(
                            id: 1,
                            type: "image",
                            url: URL(string: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d")!
                        ),
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
