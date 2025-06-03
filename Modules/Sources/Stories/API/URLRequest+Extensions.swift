import Foundation
import Networking

extension URLRequest {
    static func getUsers(page: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/users")!
        let request: URLRequest = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["page": page])
        )
        return request
    }
    
    static func getStory(userID: Int) -> URLRequest {
        let url = URL(string: "https://dummy.com/getStory")!
        let request: URLRequest = URLRequest.makeRequest(
            url: url,
            method: .get(queryParameters: ["userID": userID])
        )
        return request
    }
}
