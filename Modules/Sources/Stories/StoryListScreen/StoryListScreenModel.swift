import Observation
import Dependencies
import Foundation
import Networking

@MainActor
@Observable
public final class StoryListScreenModel {
    public init() {}

    @ObservationIgnored
    @Dependency(\.apiService) private var apiService

    var state: State = .loading
    var presentedStory: Story?
    
    @ObservationIgnored
    private var currentPage: Int = 0
    
    @ObservationIgnored
    private var viewModels: [UserItemViewModel] = []
    

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
        print("loading page = \(currentPage)")
        do {
            let users = try await apiService.request(.getUsers(page: currentPage), of: [User].self, decoder: .default)
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
                seen: false, // TODO
                onTap: { [weak self] in
//                    self?.presentedStory = user
                },
                onAppear: { [weak self] in
                    guard let self else { return }
                    self.currentPage += 1
                    await loadContent()
                }
            )
        }
    }
}

struct UserItemViewModel: Identifiable, Equatable {
    let id: Int
    let imageURL: URL
    let body: String
    let seen: Bool
    let onTap: () -> Void
    let onAppear: () async -> Void
    
    static func == (lhs: UserItemViewModel, rhs: UserItemViewModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.imageURL == rhs.imageURL &&
        lhs.body == rhs.body &&
        lhs.seen == rhs.seen
    }
}

