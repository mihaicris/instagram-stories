import Foundation

extension User {
    static func mockData(page: Int) -> [User] {
        struct JsonResponse: Codable {
            let pages: [Page]

            struct Page: Codable {
                let users: [User]
            }
        }

        do {
            guard let url = Bundle.module.url(forResource: "users", withExtension: "json") else {
                return []
            }
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            let response = try decoder.decode(JsonResponse.self, from: data)
            let wrappedIndex = page % response.pages.count  // circular access over the 3 pages --> Infinite loop
            return response.pages[wrappedIndex].users
        } catch {
            return []
        }
    }
}
