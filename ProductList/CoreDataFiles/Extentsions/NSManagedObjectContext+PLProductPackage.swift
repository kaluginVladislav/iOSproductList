//
//  NSManagedObjectContext+PLProductPackage.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 20.09.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

    func count(of visibility: PLProductPackage.Visibility) -> Int {
        let fetchRequest: NSFetchRequest<PLProductPackageManagedObject> = PLProductPackageManagedObject.fetchRequest()
        let visibilityPredicate = NSPredicate(format: "visibility == %@", visibility.rawValue)

        fetchRequest.predicate = visibilityPredicate

        do {
            return try count(for: fetchRequest)
        } catch {
            return 0
        }
    }

    @discardableResult func create(with package: PLProductPackage) -> PLProductPackageManagedObject {
        let object = PLProductPackageManagedObject(context: self)

        object.count = package.count
        object.creationDate = package.creationDate
        object.visibility = package.visibility.rawValue
        object.index = count(of: package.visibility) - 1

        if let volume = package.volume {
            object.volumeUnit = volume.unit.rawValue
            object.volumeCount = NSNumber(value: volume.count)
        }

        object.note = package.note

        let product = findOrCreate(with: package.product)

        object.product = product

        return object
    }

    @discardableResult func create(with packages: [PLProductPackage]) -> [PLProductPackageManagedObject] {
        var createdObjects: [PLProductPackageManagedObject] = []

        for package in packages {
            let createdObject = create(with: package)

            createdObjects.append(createdObject)
        }

        return createdObjects
    }

    func performCreate(with package: PLProductPackage, completion: ((PLProductPackageManagedObject) -> Void)? = nil) {
        perform {
            let object = self.create(with: package)

            completion?(object)
        }
    }

    func performCreate(with packages: [PLProductPackage], completion: (([PLProductPackageManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.create(with: packages)

            completion?(objects)
        }
    }

    func createAndSave(with package: PLProductPackage, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        let object = create(with: package)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func createAndSave(with packages: [PLProductPackage], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        let objects = create(with: packages)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(objects))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performCreateAndSave(with package: PLProductPackage, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        performCreate(with: package) { (object) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(object))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    func performCreateAndSave(with packages: [PLProductPackage], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        performFindOrCreate(with: packages) { (objects) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(objects))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    func find(with package: PLProductPackage) -> [PLProductPackageManagedObject] {
        let products = find(with: package.product)

        if let product = products.first {
            let fetchRequest: NSFetchRequest<PLProductPackageManagedObject> = PLProductPackageManagedObject.fetchRequest()

            let countPredicate = NSPredicate(format: "count == %@", package.count)
            let creationDatePredicate = NSPredicate(format: "creationDate == %@", package.creationDate as NSDate)
            let visibilityPredicate = NSPredicate(format: "visibility == %@", package.visibility.rawValue)
            let productPredicate = NSPredicate(format: "product == %@", product)

            var volumeCountPredicate: NSPredicate {
                if let volume = package.volume {
                    return NSPredicate(format: "volumeCount == %@", NSNumber(value: volume.count))
                } else {
                    return NSPredicate(format: "volumeCount == nil")
                }
            }

            var volumeUnitPredicate: NSPredicate {
                if let volume = package.volume {
                    return NSPredicate(format: "volumeUnit == %@", volume.unit.rawValue)
                } else {
                    return NSPredicate(format: "volumeUnit == nil")
                }
            }

            var notePredicate: NSPredicate {
                if let note = package.note {
                    return NSPredicate(format: "note == %@", note)
                } else {
                    return NSPredicate(format: "note == nil")
                }
            }

            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [countPredicate, creationDatePredicate, visibilityPredicate, productPredicate, volumeCountPredicate, volumeUnitPredicate, notePredicate])

            do {
                return try fetch(fetchRequest)
            } catch {
                return []
            }
        } else {
            return []
        }
    }

    func find(with packages: [PLProductPackage]) -> [PLProductPackageManagedObject] {
        var findedObjects: [PLProductPackageManagedObject] = []

        for package in packages {
            let findedObject = find(with: package)

            findedObjects += findedObject
        }

        return findedObjects
    }

    func performFind(with package: PLProductPackage, completion: (([PLProductPackageManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.find(with: package)

            completion?(objects)
        }
    }

    func performFind(with packages: [PLProductPackage], completion: (([PLProductPackageManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.find(with: packages)

            completion?(objects)
        }
    }

    func findOrCreate(with package: PLProductPackage) -> PLProductPackageManagedObject {
        let packages = find(with: package)

        if packages.count > 0 {
            return packages[0]
        } else {
            return create(with: package)
        }
    }

    func findOrCreate(with packages: [PLProductPackage]) -> [PLProductPackageManagedObject] {
        var findOrCreatedObjects: [PLProductPackageManagedObject] = []

        for package in packages {
            let findOrCreatedObject = findOrCreate(with: package)

            findOrCreatedObjects.append(findOrCreatedObject)
        }

        return findOrCreatedObjects
    }

    func performFindOrCreate(with package: PLProductPackage, completion: ((PLProductPackageManagedObject) -> Void)? = nil) {
        perform {
            let object = self.findOrCreate(with: package)

            completion?(object)
        }
    }

    func performFindOrCreate(with packages: [PLProductPackage], completion: (([PLProductPackageManagedObject]) -> Void)? = nil) {
        perform {
            let object = self.findOrCreate(with: packages)

            completion?(object)
        }
    }

    func findOrCreateAndSave(with package: PLProductPackage, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        let object = findOrCreate(with: package)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func findOrCreateAndSave(with packages: [PLProductPackage], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        let objects = findOrCreate(with: packages)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(objects))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performFindOrCreateAndSave(with package: PLProductPackage, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        performFindOrCreate(with: package) { (object) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(object))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    func performFindOrCreateAndSave(with packages: [PLProductPackage], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        performFindOrCreate(with: packages) { (objects) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(objects))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    @discardableResult func update(with package: PLProductPackage, at objectId: NSManagedObjectID) -> PLProductPackageManagedObject {
        let object = self.object(with: objectId) as! PLProductPackageManagedObject

        object.index = package.index
        object.count = package.count
        object.creationDate = package.creationDate
        object.visibility = package.visibility.rawValue

        if let volume = package.volume {
            object.volumeUnit = volume.unit.rawValue
            object.volumeCount = NSNumber(value: volume.count)
        }

        object.note = package.note

        let product = findOrCreate(with: package.product)

        object.product = product

        return object
    }

    @discardableResult func update(with packages: [PLProductPackage], at objectIds: [NSManagedObjectID]) -> [PLProductPackageManagedObject] {
        var updatedObjects: [PLProductPackageManagedObject] = []

        for (index, objectId) in objectIds.enumerated() {
            let package = packages[index]

            let updatedObject = update(with: package, at: objectId)

            updatedObjects.append(updatedObject)
        }

        return updatedObjects
    }

    func performUpdate(with package: PLProductPackage, at objectId: NSManagedObjectID, completion: ((PLProductPackageManagedObject) -> Void)? = nil) {
        perform {
            let object = self.update(with: package, at: objectId)

            completion?(object)
        }
    }

    func performUpdate(with packages: [PLProductPackage], at objectIds: [NSManagedObjectID], completion: (([PLProductPackageManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.update(with: packages, at: objectIds)

            completion?(objects)
        }
    }

    func updateAndSave(with package: PLProductPackage, at objectId: NSManagedObjectID, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        let object = update(with: package, at: objectId)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func updateAndSave(with packages: [PLProductPackage], at objectIds: [NSManagedObjectID], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        let objects = update(with: packages, at: objectIds)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(objects))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performUpdateAndSave(with package: PLProductPackage, at objectId: NSManagedObjectID, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        performUpdate(with: package, at: objectId) { (object) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(object))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    func performUpdateAndSave(with packages: [PLProductPackage], at objectIds: [NSManagedObjectID], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        performUpdate(with: packages, at: objectIds) { (objects) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(objects))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    @discardableResult func update(with package: PLProductPackage, at object: PLProductPackageManagedObject) -> PLProductPackageManagedObject {
        let object = object

        object.index = package.index
        object.count = package.count
        object.creationDate = package.creationDate
        object.visibility = package.visibility.rawValue

        if let volume = package.volume {
            object.volumeUnit = volume.unit.rawValue
            object.volumeCount = NSNumber(value: volume.count)
        }

        object.note = package.note

        let product = findOrCreate(with: package.product)

        object.product = product

        return object
    }

    @discardableResult func update(with packages: [PLProductPackage], at objects: [PLProductPackageManagedObject]) -> [PLProductPackageManagedObject] {
        var updatedObjects: [PLProductPackageManagedObject] = []

        for (index, object) in objects.enumerated() {
            let package = packages[index]

            let updatedObject = update(with: package, at: object)

            updatedObjects.append(updatedObject)
        }

        return updatedObjects
    }

    func performUpdate(with package: PLProductPackage, at object: PLProductPackageManagedObject, completion: ((PLProductPackageManagedObject) -> Void)? = nil) {
        perform {
            let object = self.update(with: package, at: object)

            completion?(object)
        }
    }

    func performUpdate(with packages: [PLProductPackage], at objects: [PLProductPackageManagedObject], completion: (([PLProductPackageManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.update(with: packages, at: objects)

            completion?(objects)
        }
    }

    func updateAndSave(with package: PLProductPackage, at object: PLProductPackageManagedObject, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        let object = update(with: package, at: object)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func updateAndSave(with packages: [PLProductPackage], at objects: [PLProductPackageManagedObject], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        let object = update(with: packages, at: objects)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performUpdateAndSave(with package: PLProductPackage, at object: PLProductPackageManagedObject, completion: ((Result<PLProductPackageManagedObject, Error>) -> Void)? = nil) {
        performUpdate(with: package, at: object) { (object) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(object))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }

    func performUpdateAndSave(with packages: [PLProductPackage], at objects: [PLProductPackageManagedObject], completion: ((Result<[PLProductPackageManagedObject], Error>) -> Void)? = nil) {
        performUpdate(with: packages, at: objects) { (objects) in
            self.performSave(completion: { (result) in
                switch result {
                case .success:
                    completion?(.success(objects))
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
        }
    }
}
