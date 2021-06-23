//
//  NSManagedObjectContext.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 20.09.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

    /// Attempts to commit unsaved changes to registered objects to the context’s parent store.
    ///
    /// - Parameters:
    ///   - completion: Completion handler.
    func save(completion: ((Result<Void, Error>) -> Void)? = nil) {
        performAndWait {
            if hasChanges {
                do {
                    try save()

                    if let parentContext = parent {
                        parentContext.save(completion: completion)
                    } else {
                        completion?(.success(()))
                    }
                } catch {
                    rollback()

                    completion?(.failure(error))
                }
            } else {
                completion?(.success(()))
            }
        }
    }

    func safelySave() throws {
        if hasChanges {
            do {
                try save()

                if let parentContext = parent {
                    try parentContext.safelySave()
                }
            } catch {
                rollback()
            }
        }
    }

    func performSave(completion: ((Result<Void, Error>) -> Void)? = nil) {
        perform {
            if self.hasChanges {
                do {
                    try self.save()

                    if let parentContext = self.parent {
                        parentContext.save(completion: completion)
                    } else {
                        completion?(.success(()))
                    }
                } catch {
                    self.rollback()

                    completion?(.failure(error))
                }
            } else {
                completion?(.success(()))
            }
        }
    }

    /// Specifies an object that should be removed by objectId from its persistent store when changes are committed.
    ///
    /// - Parameters:
    ///   - objectId: An object ID
    func delete(at objectId: NSManagedObjectID) {
        let object = self.object(with: objectId)

        delete(object)
    }

    /// Specifies an objects that should be removed by objectIds from its persistent store when changes are committed.
    ///
    /// - Parameters:
    ///   - objectIds: An object IDs
    func delete(at objectIds: [NSManagedObjectID]) {
        for objectID in objectIds {
            delete(at: objectID)
        }
    }

    /// Specifies an objects that should be removed from its persistent store when changes are committed.
    ///
    /// - Parameters:
    ///   - objects: A managed objects.
    func delete(at objects: [NSManagedObject]) {
        for object in objects {
            delete(object)
        }
    }

    /// Specifies an object that should be removed by objectId from its persistent store with attempt to commit unsaved changes.
    ///
    /// - Parameters:
    ///   - objectId: An object ID.
    ///   - completion: Completion handler.
    func delete(at objectId: NSManagedObjectID, completion: ((Result<Void, Error>) -> Void)?) {
        delete(at: objectId)

        save(completion: completion)
    }

    /// Specifies an objects that should be removed by objectId from its persistent store with attempt to commit unsaved changes.
    ///
    /// - Parameters:
    ///   - objectIds: An object IDs.
    ///   - completion: Completion handler.
    func delete(at objectIds: [NSManagedObjectID], completion: ((Result<Void, Error>) -> Void)?) {
        for objectID in objectIds {
            delete(at: objectID)
        }

        save(completion: completion)
    }

    /// Specifies an object that should be removed from its persistent store with attempt to commit unsaved changes.
    ///
    /// - Parameters:
    ///   - object: A managed object.
    ///   - completion: Completion handler.
    func delete(at object: NSManagedObject, completion: ((Result<Void, Error>) -> Void)?) {
        delete(object)

        save(completion: completion)
    }

    /// Specifies an objects that should be removed from its persistent store with attempt to commit unsaved changes.
    ///
    /// - Parameters:
    ///   - objects: A managed objects.
    ///   - completion: Completion handler.
    func delete(at objects: [NSManagedObject], completion: ((Result<Void, Error>) -> Void)?) {
        for object in objects {
            delete(object)
        }

        save(completion: completion)
    }
}
