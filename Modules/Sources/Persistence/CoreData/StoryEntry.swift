import CoreData

final class StoryEntry: NSManagedObject {
    @NSManaged var userId: Int32
    @NSManaged var liked: Bool

    static func fetchRequest() -> NSFetchRequest<StoryEntry> {
        NSFetchRequest<StoryEntry>(entityName: "StoryEntry")
    }
}
