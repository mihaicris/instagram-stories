import Foundation

public enum URLRequestMethod {
  case get(queryParameters: [String: Any]?)
  case patch(payload: Encodable?)
  case post(payload: Encodable?)
  case delete(payload: Encodable?)
  case put(payload: Encodable?)

  var httpMethod: String {
    switch self {
    case .get: "GET"
    case .patch: "PATCH"
    case .post: "POST"
    case .delete: "DELETE"
    case .put: "PUT"
    }
  }
}
