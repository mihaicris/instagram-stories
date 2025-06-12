import Kingfisher
import SwiftUI
import UIComponents

// TODO: GESTURI
// -----------------------------------
// SLIDE DOWN DISMISS IN ACCOUNT IMAGE
// ZOOM
// -----------------------------------

struct StoryViewScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset = CGSize.zero
    @State private var currentSegment: Int = 0
    @State private var segmentProgress: Double = 0.0

    let model: StoryViewScreenModel

    var body: some View {
        ZStack {
            if dragOffset.height > 0 {
                Color.black.ignoresSafeArea()
            }

            VStack(spacing: 14) {
                MediaView(
                    segments: model.segments,
                    currentSegment: $currentSegment,
                    segmentProgress: $segmentProgress
                )
                .onChange(
                    of: segmentProgress,
                    { _, newValue in
                        if newValue == 1 {
                            if currentSegment < model.segments.count - 1 {
                                currentSegment += 1
                            } else {
                                Task {
                                    await model.markAsSeen()
                                    dismiss()
                                }
                            }
                        }
                    }
                )
                .overlay(alignment: .bottomTrailing) {
                    VStack(spacing: 0) {
                        Text("\(Int(segmentProgress * 100))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("\(currentSegment + 1)/\(model.segments.count)")
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
                                    if i == currentSegment {
                                        GeometryReader { proxy in
                                            Capsule()
                                                .fill(.white)
                                                .frame(width: proxy.size.width * segmentProgress)
                                                .frame(maxHeight: .infinity)
                                        }
                                    }
                                }
                        }
                    }

                    StoryDetailsView(
                        userProfileURL: model.userProfileImageURL,
                        username: model.username,
                        activeTime: model.activeTime,
                        musicInfo: model.segments.first?.musicInfo
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
            HStack(spacing: 8) {
                KFImage(userProfileURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

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
                        .padding(.trailing)
                }

                // Story closing
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .tint(.white)
                }
            }
            .padding(.leading, 2)
            .frame(maxWidth: .infinity)
        }
    }

    struct MediaView: View {
        let segments: [StoryViewScreenModel.Segment]
        @Binding var currentSegment: Int
        @Binding var segmentProgress: Double

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    switch segments[currentSegment].type {
                    case "image":
                        ImageView(url: segments[currentSegment].url, progress: $segmentProgress)
                            .id(segments[currentSegment].id)

                    case "video":
                        VideoPlayerView(url: segments[currentSegment].url, progress: $segmentProgress)
                            .id(segments[currentSegment].id)

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
                                currentSegment += (currentSegment < segments.count - 1 ? 1 : 0)
                            } else {
                                currentSegment -= (currentSegment > 0 ? 1 : 0)
                            }
                        }
                )
                .onChange(of: currentSegment) { _, _ in
                    segmentProgress = 0.0
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
