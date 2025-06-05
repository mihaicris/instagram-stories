import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class StoryViewScreenModel {
    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    @ObservationIgnored
    let story: Story

//    let userProfileImageURL: URL
//    let username: String
//    let userVerified: Bool
//    let activeTime: String
//    let segments: [Segment]
//    let liked: Bool

    init(story: Story) {
        self.story = story
    }

    func onClose() {

    }

    func onLike() async {
        do {

        } catch {

        }
    }

    struct ViewModel {
        let userProfileImageURL: URL
        let username: String
        let userVerified: Bool
        let activeTime: String
        let segments: [Segment]
        let liked: Bool

    }

    struct Segment {
        let url: URL
        let type: String
        let musicInfo: String?
    }
}
