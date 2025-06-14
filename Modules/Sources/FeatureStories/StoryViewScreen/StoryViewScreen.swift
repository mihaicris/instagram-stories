import Kingfisher
import SwiftUI
import UIComponents

// -----------------------------------
// TODO: GESTURI SLIDE DOWN DISMISS IN ACCOUNT IMAGE
// TODO: GESTURI ZOOM
// -----------------------------------

struct StoryViewScreen: View {
    @Environment(\.dismiss) var dismiss

    let model: StoryViewScreenModel

    var body: some View {
        VStack(spacing: 14) {
            MediaView(
                segment: model.currentSegment,
                onTap: { x, width in
                    Task {
                        await model.onRegionTap(x: x, width: width)
                    }
                }
            )

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
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDissapear()
        }
        .onChange(
            of: model.shouldDismiss,
            { _, newValue in
                if newValue { dismiss() }
            }
        )
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
                                    let progress = model.progressBars[index]
                                    let width = proxy.size.width * progress
                                    Capsule()
                                        .fill(.white)
                                        .frame(width: width)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                    }
                }

                StoryDetailsView(
                    userProfileURL: model.userProfileImageURL,
                    username: model.username,
                    activeTime: model.activeTime,
                    band: model.currentSegment.band,
                    song: model.currentSegment.song,
                    onClose: model.onClose
                )
            }
            .padding(8)
        }
    }

    struct MediaView: View {
        let segment: StoryViewScreenModel.Segment
        let onTap: (_ x: CGFloat, _ width: CGFloat) -> Void

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    switch segment.type {
                    case let .image(url):
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)

                    case let .video(player):
                        VideoPlayerView(player: player)
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

    struct StoryDetailsView: View {
        let userProfileURL: URL
        let username: String
        let activeTime: String
        let band: String?
        let song: String?
        let onClose: () -> Void

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
                    if let band, let song {
                        HStack {
                            Image(systemName: "waveform")
                                .symbolEffect(.variableColor.dimInactiveLayers.cumulative.reversing)
                            Text(band).bold() + Text(" ∙ ") + Text(song)
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
                Button(action: { onClose() }) {
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
import Dependencies
import Persistence

#Preview {
    prepareDependencies {
        $0.apiService = APIServiceProvidingLocalData()
        $0.persistenceService = PersistenceServiceUserDefaults()
    }

    return StoryViewScreen(
        model: StoryViewScreenModel(
            dto: StoryViewScreenModel.DTO(
                story: .init(
                    id: 1,
                    userId: 1,
                    content: [
                        .init(
                            id: 0,
                            type: "video",
                            url: URL(string: "https://videos.pexels.com/video-files/5532765/5532765-uhd_1440_2732_25fps.mp4")!,
                            band: "Elthon John",
                            song: "Sacrifice"
                        ),
                        .init(
                            id: 1,
                            type: "image",
                            url: URL(string: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d")!,
                            band: nil,
                            song: nil
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
