import Dependencies
import Foundation
import Networking

public struct FakeAPIService: APIService {
    public init() {}

    public func request<T: Sendable & Decodable>(
        _ request: URLRequest,
        of _: T.Type,
        decoder _: JSONDecoder
    ) async throws -> T {
        try await Task.sleep(nanoseconds: 1_000_000_000)  // Simulate network delay

        let result: T? =
            fakeGetUsers(request) ?? fakeGetStory(request)

        if let result {
            return result
        }

        throw NSError(
            domain: "program_errors",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: "🔴 Fake API not implemented for request: \(request.description)"
            ]
        )
    }

    private func fakeGetUsers<T>(_ request: URLRequest) -> T? {
        guard urlPath(for: request) == "/users",
            let value = queryItemValue(for: "page", in: request),
            let page = Int(value),
            let user = User.mockData(page: page) as? T
        else {
            return nil
        }
        return user
    }

    private func fakeGetStory<T>(_ request: URLRequest) -> T? {
        guard urlPath(for: request) == "/story",
            let value = queryItemValue(for: "userID", in: request),
            let userID = Int(value),
            let story = Story.mockData(userID: userID) as? T
        else {
            return nil
        }
        return story
    }

    private func urlPath(for request: URLRequest) -> String? {
        guard let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        return components.path
    }

    private func queryItemValue(for name: String, in request: URLRequest) -> String? {
        guard let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        return components.queryItems?.first(where: { $0.name == name })?.value as? String
    }
}
