import Dependencies
import Foundation
import Networking

struct FakeAPIService: APIService {
    func request<T: Sendable & Decodable>(
        _ request: URLRequest,
        of: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network delay
        guard
            let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.path == "/users",
            let value = components.queryItems?.first(where: { $0.name == "page" })?.value as? String,
            let page = Int(value)
        else {
            return Array<User>() as! T
        }
        return User.mockData(page: page) as! T
    }
}

public func setupDependencies() {
    prepareDependencies {
        $0.apiService = FakeAPIService()
    }
}

