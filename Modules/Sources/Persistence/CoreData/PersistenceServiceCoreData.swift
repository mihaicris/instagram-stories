import CoreData

public final class PersistenceServiceCoreData {
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    nonisolated(unsafe) private let managedObjectModel: NSManagedObjectModel
    nonisolated(unsafe) private let managedObjectContext: NSManagedObjectContext

    private var context: NSManagedObjectContext {
        managedObjectContext
    }

    public init() {
        let model = NSManagedObjectModel()

        //
        let entity = NSEntityDescription()
        entity.name = StoryEntry.entityName
        entity.managedObjectClassName = NSStringFromClass(StoryEntry.self)

        let userIdAttribute = NSAttributeDescription()
        userIdAttribute.name = "userId"
        userIdAttribute.attributeType = .integer32AttributeType
        userIdAttribute.isOptional = false

        let likedAttribute = NSAttributeDescription()
        likedAttribute.name = "liked"
        likedAttribute.attributeType = .booleanAttributeType
        likedAttribute.isOptional = false
        likedAttribute.defaultValue = false

        let seenAttribute = NSAttributeDescription()
        seenAttribute.name = "seen"
        seenAttribute.attributeType = .booleanAttributeType
        seenAttribute.isOptional = false
        seenAttribute.defaultValue = false

        entity.properties = [userIdAttribute, likedAttribute, seenAttribute]
        entity.uniquenessConstraints = [["userId"]]

        model.entities = [entity]

        self.managedObjectModel = model

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        // swiftlint:disable:next force_unwrapping
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeURL = documentsDirectory.appendingPathComponent("StoryData.sqlite")

        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true,
                ]
            )
        } catch {
            fatalError("Failed to add persistent store: \(error)")
        }

        self.persistentStoreCoordinator = coordinator

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        self.managedObjectContext = context
    }

    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

extension PersistenceServiceCoreData: PersistenceService {
    public func persistStoryData(_ data: StoryData) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    // Check if entry already exists
                    let fetchRequest = StoryEntry.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userId == %d", data.userId)

                    let existingEntries = try self.context.fetch(fetchRequest)

                    let entry: StoryEntry
                    if let existingEntry = existingEntries.first {
                        // Update existing entry
                        entry = existingEntry
                    } else {
                        entry =
                            NSEntityDescription.insertNewObject(
                                forEntityName: StoryEntry.entityName,
                                into: self.context
                            ) as! StoryEntry // swiftlint:disable:this force_cast
                        entry.userId = Int32(data.userId)
                    }

                    entry.liked = data.liked
                    entry.seen = data.seen

                    try self.saveContext()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func clearStoryData(_ data: StoryData) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest = StoryEntry.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userId == %d", data.userId)

                    let entries = try self.context.fetch(fetchRequest)

                    for entry in entries {
                        self.context.delete(entry)
                    }

                    try self.saveContext()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func getPersistedStoryData(userId: Int) async throws -> StoryData? {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest = StoryEntry.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userId == %d", userId)
                    fetchRequest.fetchLimit = 1

                    let entries = try self.context.fetch(fetchRequest)

                    if let entry = entries.first {
                        let data = StoryData(userId: Int(entry.userId), liked: entry.liked, seen: entry.seen)
                        continuation.resume(returning: data)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
