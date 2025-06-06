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
            Image(systemName: liked ? "heart.fill" : "heart")
                .font(.system(size: 22, weight: .regular))
        }
        .overlay(alignment: .topTrailing) {
            if unread {
                Circle()
                    .frame(width: 9, height: 9)
                    .foregroundColor(.white)
                    .overlay {
                        Circle()
                            .frame(width: 7, height: 7)
                            .foregroundColor(.red)
                    }
            }
        }
        .padding(.horizontal, 2)
    }
}

#Preview {
    HeartButtonView(action: {}, liked: true, unread: false)
        .padding()

    HeartButtonView(action: {}, liked: false, unread: true)
        .padding()
}
