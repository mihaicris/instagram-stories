import SwiftUI
import Stories

@main
struct InstagramApp: App {
    init() {
        prepareServices()
    }
    
    var body: some Scene {
        WindowGroup {
            StoryListScreen(model: .init())
        }
    }
}
