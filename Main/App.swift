import Dependencies
import Stories
import SwiftUI

@main
struct InstagramApp: App {
    init() {
        prepareDependencies { $0.apiService = FakeAPIService() }
    }

    var body: some Scene {
        WindowGroup {
            StoryListScreen(model: .init())
        }
    }
}
