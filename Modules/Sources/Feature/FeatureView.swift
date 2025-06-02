import SwiftUI
import UIComponents

public struct FeatureView: View {
    private let model: FeatureViewModel
    
    public init(model: FeatureViewModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack {
            ComponentView()
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(model.users) { user in
                        Text(user.name)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await model.fetchData()
            }
        }
    }
}

#if MOCKING
import Dependencies
import Networking
import Mockable

let user = User(
    id: 999, name: "Mocked Name", company: "", username: "",
    email: "", address: "", zip: "", state: "", country: "",
    phone: "", photo: ""
)

#Preview {
    let mock = MockAPIService()
    given(mock)
        .request(.matching({ $0.url!.absoluteString.contains("/users") }), of: .any, decoder: .any)
        .willReturn([user])
    let _ = prepareDependencies { $0.apiService = mock }
    return FeatureView(model: .init())
}
#endif
