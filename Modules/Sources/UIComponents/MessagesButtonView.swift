import SwiftUI

public struct MessagesButtonView: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane")
                .font(.system(size: 22, weight: .regular))
        }
        .padding(.horizontal, 2)
    }
}

#Preview {
    MessagesButtonView(action: {})
}
