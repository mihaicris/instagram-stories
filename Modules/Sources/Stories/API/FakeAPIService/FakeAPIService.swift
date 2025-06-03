import Dependencies
import Foundation
import Networking

public struct FakeAPIService: APIService {
    public init() {}

    public func request<T: Sendable & Decodable>(
        _ request: URLRequest,
        of: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        //        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network delay

        let result: T? =
            fakeGetUsers(request) ?? fakeGetStory(request)

        if let result {
            return result
        } else {
            throw NSError(
                domain: "program_errors",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "🔴 Fake API not implemented for request: \(request.description)"
                ]
            )
        }
    }

    private func fakeGetUsers<T>(_ request: URLRequest) -> T? {
        guard urlPath(for: request) == "/users",
            let value = queryItemValue(for: "page", in: request),
            let page = Int(value)
        else {
            return nil
        }
        return User.mockData(page: page) as? T
    }

    private func fakeGetStory<T>(_ request: URLRequest) -> T? {
        guard urlPath(for: request) == "/story",
            let value = queryItemValue(for: "userID", in: request),
            let userID = Int(value)
        else {
            return nil
        }
        return Story(id: 1, userID: userID, mediaList: [], username: "", seen: false) as? T
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
