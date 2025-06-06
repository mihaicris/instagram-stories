import Foundation

extension Story {
    static func mockData(userId: Int) -> Story? {
        do {
            guard let url = Bundle.module.url(forResource: "stories", withExtension: "json") else {
                return nil
            }
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            let stories = try decoder.decode([Story].self, from: data)
            return stories.first { $0.userId == userId }
        } catch {
            return nil
        }
    }
}
