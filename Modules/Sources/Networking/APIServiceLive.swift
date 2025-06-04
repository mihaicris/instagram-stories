import Alamofire
import Foundation

final class APIServiceLive: APIService {
  let session: Session = {
    let configuration = URLSessionConfiguration.default
    let retrier = RetryPolicy(retryLimit: 3)
    let interceptor = Interceptor(retriers: [retrier])
    let session = Session(
      configuration: configuration,
      interceptor: interceptor,
      eventMonitors: []
    )
    return session
  }()

  func request<T: Sendable & Decodable>(
    _ request: URLRequest,
    of type: T.Type,
    decoder: JSONDecoder
  ) async throws -> T {
    let response = await session.request(request)
      .validate()
      .serializingDecodable(type.self, decoder: decoder)
      .response

    switch response.result {
    case let .success(model):
      return model

    case let .failure(error):
      throw error
    }
  }
}
