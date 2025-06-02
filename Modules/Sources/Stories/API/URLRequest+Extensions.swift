import Foundation
import Networking

extension URLRequest {
    static var getUsers: URLRequest {
        let url = URL(string: "https://dummy.com/users")!
        let request: URLRequest = URLRequest.makeRequest(url: url)
        return request
    }
}
