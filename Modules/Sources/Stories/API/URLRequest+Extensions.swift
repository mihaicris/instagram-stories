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
}
