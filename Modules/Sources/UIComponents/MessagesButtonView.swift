import SwiftUI

public struct MessagesButtonView: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    let height: CGFloat = 100
    VStack(spacing: height) {
        Group {
            MessagesButtonView(action: {})
        }
        .tint(.black)
        .frame(maxHeight: .infinity)
    }.padding(height)
}
