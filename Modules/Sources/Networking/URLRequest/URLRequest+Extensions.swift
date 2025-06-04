import Foundation

extension URLRequest {
    public static func makeRequest(
        url: URL,
        method: URLRequestMethod = .get(queryParameters: nil)
    ) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.httpMethod

        switch method {
        case .get(let queryParameters):
            if let queryParameters {
                addQueryParameters(parameters: queryParameters, to: &urlRequest)
            }

        case .patch(let payload), .post(let payload), .delete(let payload), .put(let payload):
            if let payload {
                setHTTPBody(jsonPayload: payload, to: &urlRequest)
            }
        }

        return urlRequest
    }

    public static func addQueryParameters(parameters: [String: Any], to request: inout URLRequest) {
        guard let url = request.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return
        }
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        if urlComponents.queryItems != nil {
            urlComponents.queryItems?.append(contentsOf: queryItems)
        } else {
            urlComponents.queryItems = queryItems
        }

        if let modifiedURL = urlComponents.url {
            request.url = modifiedURL
        }
    }

    public static func setHTTPBody<T: Encodable>(jsonPayload: T, to request: inout URLRequest) {
        guard let jsonData = try? JSONEncoder().encode(jsonPayload) else {
            return
        }
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
