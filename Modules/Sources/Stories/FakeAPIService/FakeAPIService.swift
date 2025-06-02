import Dependencies
import Foundation
import Networking
import Mockable

let fakeAPIService: APIService = {
    let mock = MockAPIService()
    
    let getUserRequest = Parameter<URLRequest>.matching { request in
        request.url?.absoluteString.contains("/users") ?? false
    }
    
    given(mock)
        .request(getUserRequest, of: .any, decoder: .any).willReturn(User.mockData)

    return mock
}()

public func prepareServices() {
    prepareDependencies {
        $0.apiService = fakeAPIService
    }
}

