import Foundation
import Networking

// swiftlint:disable force_unwrapping

extension URLRequest {
    static func getUser(with id: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/user")!
        let request = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["id": id])
        )
        return request
    }

    static func getUsers(page: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/users")!
        let request = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["page": page])
        )
        return request
    }

    static func getStory(userId: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/story")!
        let request = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["userId": userId])
        )
        return request
    }

    static func updateStoryLikeStatus(storyID: Int, liked: Bool) -> URLRequest {
        let url = URL(string: "https://dummy.com/story/\(storyID)")!
        struct Payload: Encodable {
            let liked: Bool
        }

        let request = URLRequest.makeRequest(
            url: url,
            method: .post(payload: Payload(liked: liked))
        )
        return request
    }
}
