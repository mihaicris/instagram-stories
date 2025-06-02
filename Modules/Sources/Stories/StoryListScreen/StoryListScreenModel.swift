import Observation
import Dependencies
import Foundation
import Networking

@MainActor
@Observable
public final class StoryListScreenModel {
    public init() {}
    
    enum State {
        case data([StoryItemViewModel])
        case empty
        case error(String)
        case loading
    }
    
    @ObservationIgnored
    @Dependency(\.apiService) private var apiService
    
    var state: State = .loading
    var presentedStory: Story?
    
    func onAppear() async {
        do {
            let users = try await apiService.request(.getUsers, of: [User].self, decoder: .init())
            dump(users)
            state = .data([])
        } catch {
            state = .error("Stories are not loading right now, try again later...")
        }
    }
    
    private func mapToViewModel(_ models: [Story]) -> [StoryItemViewModel] {
        models.map { model in
            StoryItemViewModel(
                id: model.id,
                imageURL: model.imageURL,
                body: model.username,
                seen: false,
                onTap: { [weak self] in
                    self?.presentedStory = model
                }
            )
        }
    }
}

struct StoryItemViewModel: Identifiable {
    let id: Int
    let imageURL: URL
    let body: String
    let seen: Bool
    let onTap: () -> Void
}

