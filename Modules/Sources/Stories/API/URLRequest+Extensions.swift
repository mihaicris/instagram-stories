import Foundation

extension URLRequest {
    static var getUsers: URLRequest {
        var request = URLRequest(url: URL(string: "https://dummy.com/users")!)
        request.method = .get
        request.httpBody = nil
        return request
    }
}
