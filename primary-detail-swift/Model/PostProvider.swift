//
//  PostProvider.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 5/2/22.
//

import CoreData

// Borrowed a lot of this code from the earthquakes sample
class PostProvider {
    
    /// URL for retrieving the list of posts
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    /// Provider for use within the Views
    static let shared = PostProvider()
    
    /// Provider for use with canvas previews
    static let preview: PostProvider = {
        let provider = PostProvider(inMemory: true)
        Post.makePreviews(count: 10)
        return provider
    }()
    
    // Need a better understanding what all this does
    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
        
        /// Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    
    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        
        /// PersistentContainer for the Posts Core Data
        let container = NSPersistentContainer(name: "Posts")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        /// Enable persistent store remote change notifications
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        /// Enable persistent history tracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // This sample refreshes UI by consuming store changes via persistent history tracking
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// Don't overwrite existing data
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        /// Create a private queue context.
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        taskContext.undoManager = nil
        return taskContext
    }
    
    /// Fetches posts from the URL, then imports them into the Posts Core Data
    func fetchPosts() async throws {
        /// Fetch posts from URL
        let session = URLSession.shared
        guard let (data, response) = try? await session.data(from: url),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw PostError.unexpectedError
        }
        
        /// Decode the JSON
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            /// Since the JSON is technically in an array, need to use [] around PostProperties
            let postPropertiesList = try jsonDecoder.decode([PostProperties].self, from: data)
            /// Import the JSON into Core Data
            try await importPosts(from: postPropertiesList)
        } catch {
            throw PostError.PostsError(error: error)
        }
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    private func importPosts(from propertiesList: [PostProperties]) async throws {
        /// Don't do anything if the list is empty
        guard !propertiesList.isEmpty else { return }
        
        let taskContext = newTaskContext()
        /// Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importPosts"
        
        try await taskContext.perform {
            /// Execute the batch insert
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            throw PostError.unexpectedError
        }
    }
    
    private func newBatchInsertRequest(with propertyList: [PostProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        /// Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Post.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue)
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    /// Synchronously deletes given records in the Core Data store with the specified object IDs.
//    func deletePosts(identifiedBy objectIDs: [NSManagedObjectID]) {
//        let viewContext = container.viewContext
//
//        viewContext.perform {
//            objectIDs.forEach { objectID in
//                let post = viewContext.object(with: objectID)
//                viewContext.delete(post)
//            }
//        }
//    }
    
    /// Asynchronously deletes records in the Core Data store with the specified `Post` managed objects.
    func deletePosts(_ posts: [Post]) async throws {
        let objectIDs = posts.map { $0.objectID }
        let taskContext = newTaskContext()
        /// Add name and author to identify source of persistent history changes.
        taskContext.name = "deleteContext"
        taskContext.transactionAuthor = "deletePosts"
        
        try await taskContext.perform {
            /// Execute the batch delete.
            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectIDs)
            guard let fetchResult = try? taskContext.execute(batchDeleteRequest),
                  let batchDeleteResult = fetchResult as? NSBatchDeleteResult,
                  let success = batchDeleteResult.result as? Bool, success
            else {
                throw PostError.unexpectedError
            }
        }
    }
    
    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            
        }
    }
    
    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        
        try await taskContext.perform {
            /// Execute the persistent history change since the last transaction.
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.mergePersistentHistoryChanges(from: history)
                return
            }
            
            throw PostError.unexpectedError
        }
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        /// Update view context with objectIDs from history change request.
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
}
