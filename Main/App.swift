import SwiftUI
import Stories

@main
struct InstagramApp: App {
    init() {
        setupDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            StoryListScreen(model: .init())
        }
    }
}
