//
//  CoreDataManager.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 15.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import CoreData

/// Manager for CoreData with store "ProductList".
class CoreDataManager {

    /// Instance CoreDataManager
    static let shared = CoreDataManager()

    private init() {}

    // MARK: - Contexts

    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return managedContext
    }()

    lazy var productManagedObjectContext: NSManagedObjectContext = {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.parent = managedObjectContext
        managedContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return managedContext
    }()

    lazy var productPackageManagedObjectContext: NSManagedObjectContext = {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.parent = managedObjectContext
        managedContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return managedContext
    }()

    lazy var contexts: [NSManagedObjectContext] = {
        return [managedObjectContext, productManagedObjectContext, productPackageManagedObjectContext]
    }()

    // MARK: - PersistentContainer

    /// A container that encapsulates the Core Data **ProductList** in application.
    public lazy var persistentContainer: NSPersistentContainer = {
        /*
        The persistent container for the application. This implementation
        creates and returns a container, having loaded the store for the
        application to it. This property is optional since there are legitimate
        error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ProductList")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data saving support

    /// Attempts to commit unsaved changes to store from all contexts.
    ///
    /// - Parameters:
    ///   - context: Context for saving
    ///   - completion: Completion handler
    public func saveAllContexts(completion: ((Result<Void, Error>) -> Void)? = nil) {
        var shouldEndWithError: Bool = false

        for context in contexts {
            if !shouldEndWithError {
                context.save { (result) in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        shouldEndWithError = true
                        completion?(.failure(error))
                    }
                }
            } else {
                return
            }
        }

        if !shouldEndWithError {
            completion?(.success(()))
        }
    }

    /// Attempts to commit unsaved changes to store from context.
    ///
    /// - Parameters:
    ///   - context: Context for saving
    ///   - completion: Completion handler
    func saveContext(context: NSManagedObjectContext, completion: ((Result<Void, Error>) -> Void)? = nil) {
        context.save(completion: completion)
    }
}
