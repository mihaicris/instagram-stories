import Dependencies
import Foundation
import Networking
import Mockable

let fakeAPIService: APIService = {
    let mock = MockAPIService()
    
    given(mock)
        .request(.any, of: .any, decoder: .any).willProduce { request, _, _ in
            guard
                let url = request.url,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                components.path == "/users",
                let value = components.queryItems?.first(where: { $0.name == "page" })?.value as? String,
                let page = Int(value)
            else {
                return Array<User>()
            }
            return User.mockData(page: page)
        }

    return mock
}()

public func prepareServices() {
    prepareDependencies {
        $0.apiService = fakeAPIService
    }
}

