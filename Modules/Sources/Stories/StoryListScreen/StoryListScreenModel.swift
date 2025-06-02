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

    enum State {
        case data([UserItemViewModel])
        case empty
        case error(String)
        case loading
    }

    func onAppear() async {
        do {
            let users = try await apiService.request(
                .getUsers(page: 0),
                of: [User].self,
                decoder: .default
            )
            
            let viewModels = mapToViewModel(users)
            
            state = .data(viewModels)
        } catch {
            state = .error("Stories are not loading right now, try again later...")
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
                }
            )
        }
    }
}

struct UserItemViewModel: Identifiable {
    let id: Int
    let imageURL: URL
    let body: String
    let seen: Bool
    let onTap: () -> Void
}

