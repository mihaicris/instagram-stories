import Foundation
import Networking

// swiftlint:disable force_unwrapping

extension URLRequest {
    static func getUsers(page: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/users")!
        let request = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["page": page])
        )
        return request
    }

    static func getStory(userID: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/story")!
        let request = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["userID": userID])
        )
        return request
    }
}
