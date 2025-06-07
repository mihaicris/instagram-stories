import Dependencies
import FeatureStories
import Persistence
import SwiftUI

@main
struct InstagramApp: App {
    init() {
        prepareDependencies {
            $0.apiService = APIServiceProvidingLocalData()
            $0.persistenceService = PersistenceServiceCoreData()
        }
    }

    var body: some Scene {
        WindowGroup {
            StoryListScreen(model: .init())
        }
    }
}
