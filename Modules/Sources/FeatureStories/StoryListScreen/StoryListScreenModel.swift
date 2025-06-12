import Dependencies
import Foundation
import Networking
import Observation
import Persistence

@MainActor
@Observable
public final class StoryListScreenModel {
    public init() {}

    var state: State = .loading
    var isLoadingMore: Bool = false
    var navigationToStory: StoryViewScreenModel.DTO?

    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    @ObservationIgnored
    @Dependency(\.persistenceService) private var persistenceService

    @ObservationIgnored
    private var currentPage: Int = 0

    @ObservationIgnored
    private var viewModels: [StoryItemViewModel] = []

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
        logger.info("Loading page \(self.currentPage, privacy: .public)")
        isLoadingMore = !viewModels.isEmpty
        defer { isLoadingMore = false }
        do {
            let users: [User] = try await apiService.request(.getUsers(page: currentPage), of: [User].self, decoder: .default)
            let newViewModels = try await makeViewModels(users: users)
            viewModels += newViewModels
            state = .data(viewModels)
        } catch {
            state = .error("Stories are not loading right now, try again later...")
            currentPage = 0
            viewModels = []
        }
    }

    func refresh(user: User) async {
        guard
            let index = viewModels.firstIndex(where: { $0.id == user.id }),
            let viewModel = try? await makeViewModel(for: user)
        else {
            return
        }
        viewModels[index] = viewModel
        state = .data(viewModels)
    }
    
    // MARK: - Private

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

            // I make the random results in the same order as the users list
            let sorted = users.compactMap { resultsById[$0.id] }

            return sorted
        }
    }

    private func makeViewModel(for user: User) async throws -> StoryItemViewModel? {
        guard let imageURL = URL(string: user.profilePictureURL) else {
            return nil
        }
        let persistedData = try await persistenceService.getPersistedStoryData(userId: user.id)
        return StoryItemViewModel(
            id: user.id,
            imageURL: imageURL,
            username: user.name,
            seen: persistedData != nil,
            onTap: { [weak self] in
                guard let self else {
                    return
                }
                await onUserTap(user)
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

    private func onUserTap(_ user: User) async {
        do {
            var story: Story = try await apiService.request(.getStory(userId: user.id), of: Story.self, decoder: .default)
            story = try await updateStoryPersistence(for: story)
            navigationToStory = StoryViewScreenModel.DTO(story: story, user: user)
        } catch {
            logger.error("Couldn't get user story: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func updateStoryPersistence(for story: Story) async throws -> Story {
        if let persistedStory = try await persistenceService.getPersistedStoryData(userId: story.userId) {
            return Story(
                id: story.id,
                userId: story.userId,
                content: story.content,
                seen: true,
                liked: persistedStory.liked
            )
        }
        let data = StoryData(userId: story.userId, liked: story.liked, seen: story.seen)
        try await persistenceService.persistStoryData(data)
        return Story(
            id: story.id,
            userId: story.userId,
            content: story.content,
            seen: story.seen,
            liked: story.liked
        )
    }
}
