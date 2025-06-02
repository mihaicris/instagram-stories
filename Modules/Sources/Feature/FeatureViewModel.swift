import Dependencies
import Foundation
import Observation
import Networking

@MainActor
@Observable
public final class FeatureViewModel {
    public init() {}
    
    var users: [User] = []
    
    @ObservationIgnored
    @Dependency(\.apiService) private var apiService
    
    func fetchData() async {
        let request = URLRequest(url: URL(string: "https://fake-json-api.mock.beeceptor.com/users")!)
        do {
            users = try await apiService.request(request, of: [User].self, decoder: JSONDecoder())
        } catch {
            dump(error)
        }
    }
}

