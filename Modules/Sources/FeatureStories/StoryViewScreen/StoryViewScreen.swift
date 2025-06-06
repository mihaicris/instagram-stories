import Kingfisher
import SwiftUI
import UIComponents

// TODO: GESTURI
// -----------------------------------
// TAP STANGA
// TAP DREAPTA
// SLIDE DOWN DISMISS IN ACCOUNT IMAGE
// ZOOM
// -----------------------------------

struct StoryViewScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset = CGSize.zero

    let model: StoryViewScreenModel

    var body: some View {
        ZStack {
            if dragOffset.height > 0 {
                Color.black.ignoresSafeArea()
            }

            VStack(spacing: 14) {
                MediaView(url: model.story.content.first!.url)

                HStack(spacing: 12) {
                    MesssageInputButtonView(action: {})
                    HeartButtonView(action: {}, unread: false)
                    MessagesButtonView(action: {})
                }
                .tint(.white)
                .padding(.horizontal, 20)
            }
            .background(Color.black)
            .overlay(alignment: .top) {
                StoryDetailsView().padding(8)
            }
            .offset(y: dragOffset.height)
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
        }
    }

    struct StoryDetailsView: View {
        let segments: Int = 10
        var body: some View {
            VStack(spacing: 6) {
                HStack(spacing: 3) {  // DISTANCE BETWEEN SEGMENTS
                    ForEach(1...segments, id: \.self) { i in
                        Capsule().fill(.white)
                            .opacity(0.3)
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .leading) {
                                if i == 1 {
                                    Capsule().fill(.white)
                                }
                            }
                    }
                }
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 30, height: 30)

                    VStack(alignment: .leading) {
                        Text("trusca_simona ").bold()
                            + Text("2h")
                            .foregroundStyle(.white.opacity(0.8))
                        HStack {
                            Image(systemName: "waveform")
                                .symbolEffect(.variableColor.dimInactiveLayers.cumulative.reversing)
                            Text("Kali Uchis ∙").bold() + Text("All I can say")
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
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .tint(.white)
                    }
                }
                .padding(2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct MediaView: View {
        let url: URL

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
#Preview {
    StoryViewScreen(
        model: .init(
            story: .init(
                id: 1,
                userID: 1,
                content: [
                    .init(
                        id: 0,
                        type: "image",
                        url: URL(string: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d")!
                    ),
                    .init(
                        id: 1,
                        type: "image",
                        url: URL(string: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d")!
                    ),
                ],
                seen: true,
                liked: false
            )
        )
    )
}
