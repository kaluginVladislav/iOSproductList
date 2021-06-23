//
//  PLProductManagedObject.swift
//  
//
//  Created by Vladislav Kalugin on 13.09.2020.
//
//

import CoreData

public class PLProductManagedObject: NSManagedObject {

    @NSManaged public var emoji: String
    @NSManaged public var name: String
    @NSManaged public var origin: String

}

extension PLProductManagedObject {

    public static let entityName: String = "PLProduct"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PLProductManagedObject> {
        return NSFetchRequest<PLProductManagedObject>(entityName: entityName)
    }
}
