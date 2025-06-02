//
//  StoryDetailsScreen.swift
//  Instagram
//
//  Created by Mihai Cristescu on 28.05.2025.
//

import Kingfisher
import SwiftUI
import UIComponents

struct StoryViewScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset = CGSize.zero

    let model: StoryViewScreenModel
    let url = URL(
        string: "https://plus.unsplash.com/premium_photo-1664015982534-5837663d1d73?q=80&w=1965&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    )!
    
    var body: some View {
        ZStack {
            if dragOffset.height > 0 {
                Color.black.ignoresSafeArea()
            }
            
            VStack(spacing: 12) {
                MediaView(url: url)
                HStack {
                    MesssageInputButtonView(action: {})
                    HeartButtonView(action: {}, unread: false)
                    MessagesButtonView(action: {})
                }
                .tint(.white)
                .padding(.horizontal, 8)
            }
            .background(Color.black)
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
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay {
                        Capsule()
                            .stroke(.white, lineWidth: 0.5)
                            .padding(2)
                    }
            }
        }
    }

}

#Preview {
    StoryViewScreen(
        model: .init(
            story: .init(
                id: 1,
                imageURL: .applicationDirectory,
                username: "mihai",
                seen: false
            )
        )
    )
}
