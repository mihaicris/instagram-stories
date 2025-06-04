import Dependencies
import Observation

@MainActor
@Observable
final class StoryViewScreenModel {
  let story: Story

  init(story: Story) {
    self.story = story
  }
}
