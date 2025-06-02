//
//  MessagesButtonView.swift
//  Instagram
//
//  Created by Mihai Cristescu on 28.05.2025.
//

import SwiftUI

public struct MessagesButtonView: View {
    let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane")
                .font(.system(size: 20,weight: .regular))
        }
        .padding(.horizontal, 2)
    }
}
