//
//  PLProductPackageManagedObject.swift
//  
//
//  Created by Vladislav Kalugin on 13.09.2020.
//
//

import CoreData

public class PLProductPackageManagedObject: NSManagedObject {

    @NSManaged public var index: Int
    @NSManaged public var count: Int
    @NSManaged public var creationDate: Date
    @NSManaged public var visibility: String
    @NSManaged public var product: PLProductManagedObject
    @NSManaged public var volumeCount: NSNumber?
    @NSManaged public var volumeUnit: String?
    @NSManaged public var note: String?

}

extension PLProductPackageManagedObject {

    public static let entityName: String = "PLProductPackage"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PLProductPackageManagedObject> {
        return NSFetchRequest<PLProductPackageManagedObject>(entityName: entityName)
    }
}
