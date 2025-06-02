import SwiftUI

public struct ComponentView: View {
    public init() {}
    
    private let size: CGFloat = 48
    private let lineWidth: CGFloat = 2
    
    public var body: some View {
        Grid {
            ForEach(1...2, id: \.self) { _ in
                GridRow {
                    ForEach(1...2, id: \.self) { _ in
                        Circle()
                            .fill(.red)
                            .stroke(Color.primary, lineWidth: lineWidth)
                            .frame(width: size, height: size)
                    }
                }
            }
        }
    }
}
