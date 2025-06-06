import Dependencies
import Foundation
import Networking
import Observation
import Persistence

@MainActor
@Observable
public final class StoryListScreenModel {
    public init() {}

    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    @ObservationIgnored
    @Dependency(\.persistenceService) private var persistenceService

    var state: State = .loading
    var isLoadingMore: Bool = false
    var navigationToStory: Story?

    @ObservationIgnored private var currentPage: Int = 0

    @ObservationIgnored private var storyViewModels: [StoryItemViewModel] = []

    enum State: Equatable {
        case data([StoryItemViewModel])
        case empty
        case error(String)
        case loading
    }

    func onAppear() async {
        currentPage = 0
        await loadMoreContent()
    }

    func loadMoreContent() async {
        isLoadingMore = !storyViewModels.isEmpty
        defer { isLoadingMore = false }
        do {
            let users: [User] = try await apiService.request(
                .getUsers(page: currentPage),
                of: [User].self,
                decoder: .default
            )
            let new = try await makeViewModels(users: users)
            storyViewModels += new
            state = .data(storyViewModels)
        } catch {
            state = .error("Stories are not loading right now, try again later...")
            currentPage = 0
            storyViewModels = []
        }
    }
    
    private func makeViewModels(users: [User]) async throws -> [StoryItemViewModel] {
        try await withThrowingTaskGroup(of: StoryItemViewModel?.self, returning: [StoryItemViewModel].self) { taskGroup in
            for user in users {
                taskGroup.addTask { [weak self] in
                    try await self?.makeViewModel(for: user)
                }
            }
            
            var resultsById: [User.ID: StoryItemViewModel] = [:]

            for try await result in taskGroup {
                if let vm = result {
                    resultsById[vm.id] = vm
                }
            }

            let sorted = users.compactMap { resultsById[$0.id] }

            return sorted
        }
    }
    
    private func makeViewModel(for user: User) async throws -> StoryItemViewModel? {
        guard let imageURL = URL(string: user.profilePictureURL) else {
            return nil
        }
        let persistedData = try await persistenceService.getPersistedStoryData(userID: user.id)
        return StoryItemViewModel(
            id: user.id,
            imageURL: imageURL,
            body: user.name,
            seen: persistedData != nil,
            onTap: { [weak self] in
                guard let self else {
                    return
                }
                await onUserTap(userID: user.id)
            },
            onAppear: { [weak self] in
                guard let self else {
                    return
                }
                await MainActor.run {
                    self.currentPage += 1
                }
                await loadMoreContent()
            }
        )
    }

    private func onUserTap(userID: Int) async {
        do {
            let story: Story = try await apiService.request(
                .getStory(userID: userID),
                of: Story.self,
                decoder: .default
            )
            navigationToStory = try await updateStoryPersistence(for: story)
        } catch {
            // TODO: Error logging
        }
    }

    private func updateStoryPersistence(for story: Story) async throws -> Story {
        if let persistedStory = try await persistenceService.getPersistedStoryData(userID: story.userID) {
            return Story(
                id: story.id,
                userID: story.userID,
                content: story.content,
                seen: true,
                liked: persistedStory.liked
            )
        }
        try await persistenceService.persistStoryData(StoryPersistedData(userID: story.userID, liked: story.liked))
        return Story(
            id: story.id,
            userID: story.userID,
            content: story.content,
            seen: true,  // tapping on a story will mark story as seen, and persist
            liked: story.liked
        )
    }
}
