import Alamofire
import Dependencies
import Foundation
import Mockable

@Mockable
public protocol APIService: Sendable {
    func request<T: Sendable & Decodable>(
        _ request: URLRequest,
        of: T.Type,
        decoder: JSONDecoder
    ) async throws -> T
}

public enum APIServiceKey: DependencyKey {
    static public let liveValue: APIService = APIServiceLive()
}

extension DependencyValues {
    public var apiService: APIService {
      get { self[APIServiceKey.self] }
      set { self[APIServiceKey.self] = newValue }
    }
}
