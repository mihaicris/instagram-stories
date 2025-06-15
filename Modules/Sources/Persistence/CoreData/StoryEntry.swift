import CoreData

final class StoryEntry: NSManagedObject {
    @NSManaged var userID: Int32
    @NSManaged var liked: Bool
    @NSManaged var seen: Bool

    static let entityName = "StoryEntry"

    static func fetchRequest() -> NSFetchRequest<StoryEntry> {
        NSFetchRequest<StoryEntry>(entityName: entityName)
    }
}
