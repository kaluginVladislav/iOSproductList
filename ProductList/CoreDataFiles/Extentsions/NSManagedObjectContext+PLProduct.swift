//
//  NSManagedObjectContext+PLProduct.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 20.09.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

    @discardableResult func create(with product: PLProduct) -> PLProductManagedObject {
        let object = PLProductManagedObject(context: self)

        object.emoji = product.emoji
        object.name = product.name
        object.origin = product.origin

        return object
    }

    @discardableResult func create(with products: [PLProduct]) -> [PLProductManagedObject] {
        var createdObjects: [PLProductManagedObject] = []

        for product in products {
            let createdObject = create(with: product)

            createdObjects.append(createdObject)
        }

        return createdObjects
    }

    func performCreate(with product: PLProduct, completion: ((PLProductManagedObject) -> Void)? = nil) {
        perform {
            let object = self.create(with: product)

            completion?(object)
        }
    }

    func performCreate(with products: [PLProduct], completion: (([PLProductManagedObject]) -> Void)? = nil) {
        perform {
            let object = self.create(with: products)

            completion?(object)
        }
    }

    func createAndSave(with product: PLProduct, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        let object = create(with: product)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func createAndSave(with products: [PLProduct], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        let objects = create(with: products)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(objects))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performCreateAndSave(with product: PLProduct, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        performCreate(with: product) { (object) in
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

    func performCreateAndSave(with products: [PLProduct], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        performFindOrCreate(with: products) { (objects) in
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

    func find(with product: PLProduct) -> [PLProductManagedObject] {
        let fetchRequest: NSFetchRequest<PLProductManagedObject> = PLProductManagedObject.fetchRequest()

        let namePredicate = NSPredicate(format: "name = %@", product.name)
        let emojiPredicate = NSPredicate(format: "emoji = %@", product.emoji)

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, emojiPredicate])

        do {
            return try fetch(fetchRequest)
        } catch {
            return []
        }
    }

    func find(with products: [PLProduct]) -> [PLProductManagedObject] {
        var findedObjects: [PLProductManagedObject] = []

        for product in products {
            let findedObject = find(with: product)

            findedObjects += findedObject
        }

        return findedObjects
    }

    func performFind(with product: PLProduct, completion: (([PLProductManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.find(with: product)

            completion?(objects)
        }
    }

    func performFind(with products: [PLProduct], completion: (([PLProductManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.find(with: products)

            completion?(objects)
        }
    }

    func findOrCreate(with product: PLProduct) -> PLProductManagedObject {
        let products = find(with: product)

        if products.count > 0 {
            return products[0]
        } else {
            return create(with: product)
        }
    }

    func findOrCreate(with products: [PLProduct]) -> [PLProductManagedObject] {
        var findOrCreatedObjects: [PLProductManagedObject] = []

        for product in products {
            let findOrCreatedObject = findOrCreate(with: product)

            findOrCreatedObjects.append(findOrCreatedObject)
        }

        return findOrCreatedObjects
    }

    func performFindOrCreate(with product: PLProduct, completion: ((PLProductManagedObject) -> Void)? = nil) {
        perform {
            let object = self.findOrCreate(with: product)

            completion?(object)
        }
    }

    func performFindOrCreate(with products: [PLProduct], completion: (([PLProductManagedObject]) -> Void)? = nil) {
        perform {
            let object = self.findOrCreate(with: products)

            completion?(object)
        }
    }

    func findOrCreateAndSave(with product: PLProduct, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        let object = findOrCreate(with: product)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func findOrCreateAndSave(with products: [PLProduct], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        let objects = findOrCreate(with: products)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(objects))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performFindOrCreateAndSave(with product: PLProduct, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        performFindOrCreate(with: product) { (object) in
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

    func performFindOrCreateAndSave(with products: [PLProduct], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        performFindOrCreate(with: products) { (objects) in
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

    @discardableResult func update(with product: PLProduct, at objectId: NSManagedObjectID) -> PLProductManagedObject {
        let object = self.object(with: objectId) as! PLProductManagedObject

        object.emoji = product.emoji
        object.name = product.name
        object.origin = product.origin

        return object
    }

    @discardableResult func update(with products: [PLProduct], at objectIds: [NSManagedObjectID]) -> [PLProductManagedObject] {
        var updatedObjects: [PLProductManagedObject] = []

        for (index, objectId) in objectIds.enumerated() {
            let product = products[index]

            let updatedObject = update(with: product, at: objectId)

            updatedObjects.append(updatedObject)
        }

        return updatedObjects
    }

    func performUpdate(with product: PLProduct, at objectId: NSManagedObjectID, completion: ((PLProductManagedObject) -> Void)? = nil) {
        perform {
            let object = self.update(with: product, at: objectId)

            completion?(object)
        }
    }

    func performUpdate(with products: [PLProduct], at objectIds: [NSManagedObjectID], completion: (([PLProductManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.update(with: products, at: objectIds)

            completion?(objects)
        }
    }

    func updateAndSave(with product: PLProduct, at objectId: NSManagedObjectID, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        let object = update(with: product, at: objectId)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func updateAndSave(with products: [PLProduct], at objectIds: [NSManagedObjectID], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        let objects = update(with: products, at: objectIds)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(objects))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performUpdateAndSave(with product: PLProduct, at objectId: NSManagedObjectID, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        performUpdate(with: product, at: objectId) { (object) in
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

    func performUpdateAndSave(with products: [PLProduct], at objectIds: [NSManagedObjectID], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        performUpdate(with: products, at: objectIds) { (objects) in
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

    @discardableResult func update(with product: PLProduct, at object: PLProductManagedObject) -> PLProductManagedObject {
        let object = object

        object.emoji = product.emoji
        object.name = product.name
        object.origin = product.origin

        return object
    }

    @discardableResult func update(with products: [PLProduct], at objects: [PLProductManagedObject]) -> [PLProductManagedObject] {
        var updatedObjects: [PLProductManagedObject] = []

        for (index, object) in objects.enumerated() {
            let product = products[index]

            let updatedObject = update(with: product, at: object)

            updatedObjects.append(updatedObject)
        }

        return updatedObjects
    }

    func performUpdate(with product: PLProduct, at object: PLProductManagedObject, completion: ((PLProductManagedObject) -> Void)? = nil) {
        perform {
            let object = self.update(with: product, at: object)

            completion?(object)
        }
    }

    func performUpdate(with products: [PLProduct], at objects: [PLProductManagedObject], completion: (([PLProductManagedObject]) -> Void)? = nil) {
        perform {
            let objects = self.update(with: products, at: objects)

            completion?(objects)
        }
    }

    func updateAndSave(with product: PLProduct, at object: PLProductManagedObject, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        let object = update(with: product, at: object)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func updateAndSave(with products: [PLProduct], at objects: [PLProductManagedObject], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        let object = update(with: products, at: objects)

        save(completion: { (result) in
            switch result {
            case .success:
                completion?(.success(object))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func performUpdateAndSave(with product: PLProduct, at object: PLProductManagedObject, completion: ((Result<PLProductManagedObject, Error>) -> Void)? = nil) {
        performUpdate(with: product, at: object) { (object) in
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

    func performUpdateAndSave(with products: [PLProduct], at objects: [PLProductManagedObject], completion: ((Result<[PLProductManagedObject], Error>) -> Void)? = nil) {
        performUpdate(with: products, at: objects) { (objects) in
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
