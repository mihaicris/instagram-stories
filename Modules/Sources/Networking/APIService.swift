import Alamofire
import Dependencies
import Foundation

public protocol APIService: Sendable {
    func request<T: Sendable & Decodable>(
        _ request: URLRequest,
        of: T.Type,
        decoder: JSONDecoder
    ) async throws -> T
}

extension DependencyValues {
    public enum APIServiceKey: DependencyKey {
        public static let liveValue: APIService = APIServiceLive()
    }

    public var apiService: APIService {
        get { self[APIServiceKey.self] }
        set { self[APIServiceKey.self] = newValue }
    }
}
