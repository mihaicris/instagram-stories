import SwiftUI

public struct HeartButtonView: View {
    let action: () -> Void
    let liked: Bool
    let unread: Bool

    public init(action: @escaping () -> Void, liked: Bool, unread: Bool) {
        self.action = action
        self.liked = liked
        self.unread = unread
    }

    public var body: some View {
        Button(action: action) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let clipSize = width / 2.8
                let offset = clipSize / 4.0
                let ratio: CGFloat = 1.3
                let maskSize = clipSize * ratio
                let alignmentFix = (maskSize - clipSize) / 2

                if unread {
                    ZStack(alignment: .topTrailing) {
                        heart()
                            .mask {
                                ZStack(alignment: .topTrailing) {
                                    Rectangle()
                                    Circle()
                                        .frame(width: clipSize * ratio, height: clipSize * ratio)
                                        .offset(x: offset, y: -offset)
                                        .blendMode(.destinationOut)
                                }
                            }

                        Circle()
                            .fill(.red)
                            .frame(width: clipSize, height: clipSize)
                            .offset(x: offset - alignmentFix, y: -offset + alignmentFix)
                    }
                } else {
                    heart()
                }
            }
            .aspectRatio(contentMode: .fit)
        }
    }

    @ViewBuilder
    private func heart() -> some View {
        Image(systemName: liked ? "heart.fill" : "heart")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .font(.system(size: 24, weight: .medium))  // font size is ignored
    }
}

#Preview {
    let height: CGFloat = 60
    VStack(spacing: height) {
        Group {
            HeartButtonView(action: {}, liked: true, unread: false)
            HeartButtonView(action: {}, liked: true, unread: true)
            HeartButtonView(action: {}, liked: false, unread: false)
            HeartButtonView(action: {}, liked: false, unread: true)
        }
        .tint(.black)
        .frame(maxHeight: .infinity)
    }.padding(height)
}
