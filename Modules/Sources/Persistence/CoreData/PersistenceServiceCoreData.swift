import CoreData

// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast

public final class PersistenceServiceCoreData {
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    nonisolated(unsafe) private let managedObjectModel: NSManagedObjectModel
    nonisolated(unsafe) private let managedObjectContext: NSManagedObjectContext

    private var context: NSManagedObjectContext {
        managedObjectContext
    }

    public init() {
        // Create the managed object model
        let model = NSManagedObjectModel()

        // Create entity description
        let entity = NSEntityDescription()
        entity.name = "StoryEntry"
        entity.managedObjectClassName = NSStringFromClass(StoryEntry.self)

        // Create attributes
        let userIdAttribute = NSAttributeDescription()
        userIdAttribute.name = "userId"
        userIdAttribute.attributeType = .integer32AttributeType
        userIdAttribute.isOptional = false

        let likedAttribute = NSAttributeDescription()
        likedAttribute.name = "liked"
        likedAttribute.attributeType = .booleanAttributeType
        likedAttribute.isOptional = false
        likedAttribute.defaultValue = false

        // Add attributes to entity
        entity.properties = [userIdAttribute, likedAttribute]

        // Add entity to model
        model.entities = [entity]

        self.managedObjectModel = model

        // Create the persistent store coordinator
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        // Get documents directory URL
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
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

        // Create the managed object context
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        self.managedObjectContext = context
    }

    // MARK: - Core Data Saving Support
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

extension PersistenceServiceCoreData: PersistenceService {
    public func persistStoryData(_ data: StoryPersistedData) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    // Check if entry already exists
                    let fetchRequest: NSFetchRequest<StoryEntry> = StoryEntry.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userId == %d", data.userId)

                    let existingEntries = try self.context.fetch(fetchRequest)

                    let entry: StoryEntry
                    if let existingEntry = existingEntries.first {
                        // Update existing entry
                        entry = existingEntry
                    } else {
                        // Create new entry
                        entry = NSEntityDescription.insertNewObject(forEntityName: "StoryEntry", into: self.context) as! StoryEntry
                        entry.userId = Int32(data.userId)
                    }

                    entry.liked = data.liked

                    try self.saveContext()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func clearStoryData(_ data: StoryPersistedData) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<StoryEntry> = StoryEntry.fetchRequest()
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

    public func getPersistedStoryData(userId: Int) async throws -> StoryPersistedData? {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<StoryEntry> = StoryEntry.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userId == %d", userId)
                    fetchRequest.fetchLimit = 1

                    let entries = try self.context.fetch(fetchRequest)

                    if let entry = entries.first {
                        let data = StoryPersistedData(
                            userId: Int(entry.userId),
                            liked: entry.liked
                        )
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
