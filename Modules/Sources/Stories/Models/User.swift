import Foundation

public struct User: Codable, Identifiable, Sendable, Equatable {
  public let id: Int
  public let name: String
  public let profilePictureURL: String

  public init(id: Int, name: String, profilePictureURL: String) {
    self.id = id
    self.name = name
    self.profilePictureURL = profilePictureURL
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case profilePictureURL = "profile_picture_url"
  }
}
