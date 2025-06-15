import Dependencies
import FeatureStories
import Persistence
import SwiftUI

@main
struct InstagramApp: App {
    init() {
        if !isRunningPreviews {
            prepareDependencies {
                $0.apiService = APIServiceProvidingLocalData()
                $0.persistenceService = PersistenceServiceCoreData()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            StoryListScreen(model: .init())
            // TestView(model: .init())
        }
    }

    private var isRunningPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
