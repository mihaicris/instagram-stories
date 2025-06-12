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
            // $0.persistenceService = PersistenceServiceUserDefaults()
        }
    }

    var body: some Scene {
        WindowGroup {
            StoryListScreen(model: .init())
        }
    }
}
