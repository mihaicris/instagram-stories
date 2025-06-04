import SwiftUI

public struct HeartButtonView: View {
  let action: () -> Void
  let unread: Bool

  public init(action: @escaping () -> Void, unread: Bool) {
    self.action = action
    self.unread = unread
  }

  public var body: some View {
    Button(action: action) {
      Image(systemName: "heart")
        .font(.system(size: 20, weight: .regular))
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
  HeartButtonView(action: {}, unread: true)
    .padding()

  HeartButtonView(action: {}, unread: false)
    .padding()
}
