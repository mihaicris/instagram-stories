import Dependencies
import Foundation
import Networking

public struct FakeAPIService: APIService {
    public init() {}

    public func request(_ request: URLRequest) throws {
        // swiftlint:disable:next unused_optional_binding
        guard let _ = try? fakeUpdateStoryLikeStatus(request) else {
            throw NSError.notImplemented(request)
        }
    }

    public func request<T: Sendable & Decodable>(
        _ request: URLRequest,
        of _: T.Type,
        decoder _: JSONDecoder
    ) async throws -> T {
        try await Task.sleep(nanoseconds: 0_000_000_001)  // Simulate network delay

        let result: T? =
            fakeGetUsers(request)
            ?? fakeGetUserWithID(request)
            ?? fakeGetStory(request)

        if let result {
            return result
        }

        throw NSError.notImplemented(request)
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

    private func fakeGetUserWithID<T>(_ request: URLRequest) -> T? {
        guard urlPath(for: request) == "/user",
            let value = queryItemValue(for: "id", in: request),
            let id = Int(value),
            let user = User.mockUser(id: id) as? T
        else {
            return nil
        }
        return user
    }

    private func fakeGetStory<T>(_ request: URLRequest) -> T? {
        guard urlPath(for: request) == "/story",
            let value = queryItemValue(for: "userId", in: request),
            let userId = Int(value),
            let story = Story.mockData(userId: userId) as? T
        else {
            return nil
        }
        return story
    }

    private func fakeUpdateStoryLikeStatus(_ request: URLRequest) throws {
        guard urlPath(for: request) == "/story/"
        else {
            throw NSError.notImplemented(request)
        }
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

extension NSError {
    static func notImplemented(_ request: URLRequest) -> NSError {
        NSError(
            domain: "program_errors",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: "🔴 Fake API not implemented for request: \(request.description)"
            ]
        )
    }
}
