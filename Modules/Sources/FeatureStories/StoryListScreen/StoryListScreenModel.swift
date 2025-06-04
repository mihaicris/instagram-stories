import Dependencies
import Foundation
import Networking
import Observation

@MainActor
@Observable
public final class StoryListScreenModel {
    public init() {}

    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    var state: State = .loading
    var isLoadingMore: Bool = false
    var presentedStory: Story?

    @ObservationIgnored private var currentPage: Int = 0

    @ObservationIgnored private var viewModels: [UserItemViewModel] = []

    enum State: Equatable {
        case data([UserItemViewModel])
        case empty
        case error(String)
        case loading
    }

    func onAppear() async {
        currentPage = 0
        await loadContent()
    }

    func loadContent() async {
        isLoadingMore = !viewModels.isEmpty
        defer { isLoadingMore = false }
        do {
            let users: [User] = try await apiService.request(
                .getUsers(page: currentPage),
                of: [User].self,
                decoder: .default
            )
            viewModels += mapToViewModel(users)
            state = .data(viewModels)
        } catch {
            state = .error("Stories are not loading right now, try again later...")
            currentPage = 0
            viewModels = []
        }
    }

    private func mapToViewModel(_ users: [User]) -> [UserItemViewModel] {
        users.compactMap { user in
            guard let imageURL = URL(string: user.profilePictureURL) else {
                return nil
            }

            return UserItemViewModel(
                id: user.id,
                imageURL: imageURL,
                body: user.name,
                seen: false,  // TODO: Implement this
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
                    currentPage += 1
                    await loadContent()
                }
            )
        }
    }

    private func onUserTap(userID: Int) async {
        do {
            let story: Story = try await apiService.request(
                .getStory(userID: userID),
                of: Story.self,
                decoder: .default
            )
            dump(story)
        } catch {
            // TODO: Implement this
            print(error.localizedDescription)
        }
    }
}
