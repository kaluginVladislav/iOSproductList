//
//  PLProduct.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 21.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import Foundation

struct PLProduct {

    public var emoji: String
    public var name: String
    public var origin: String

    init(emoji: String, name: String, origin: String) {
        self.emoji = emoji
        self.name = name
        self.origin = origin
    }

    init(managedObject: PLProductManagedObject) {
        self.emoji = managedObject.emoji
        self.name = managedObject.name
        self.origin = managedObject.origin
    }
}
