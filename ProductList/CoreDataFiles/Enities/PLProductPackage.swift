//
//  PLProductPackage.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 13.09.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import Foundation

struct PLProductPackage {

    enum Visibility: String {

        case list

        case basket

        case unknown

    }

    struct Volume {

        enum Unit: String {

            case gr

            case kg

            case ml

            case l

        }

        let unit: Unit
        let count: Int

        init(unit: Unit, count: Int) {
            self.unit = unit
            self.count = count
        }
    }

    public var index: Int
    public var count: Int
    public var creationDate: Date
    public var visibility: Visibility
    public var product: PLProduct
    public var volume: Volume?
    public var note: String?

    init(index: Int, count: Int, creationDate: Date, visibility: Visibility, product: PLProduct, volume: Volume?, note: String?) {
        self.index = index
        self.count = count
        self.creationDate = creationDate
        self.visibility = visibility
        self.product = product
        self.volume = volume
        self.note = note
    }

    init(managedObject: PLProductPackageManagedObject) {
        self.index = managedObject.index
        self.count = managedObject.count
        self.creationDate = managedObject.creationDate
        self.visibility = Visibility(rawValue: managedObject.visibility) ?? .unknown
        self.product = PLProduct(managedObject: managedObject.product)

        if let volumeCount = managedObject.volumeCount,
           let volumeUnit = managedObject.volumeUnit, let unit = Volume.Unit(rawValue: volumeUnit) {
            self.volume = Volume(unit: unit, count: volumeCount.intValue)
        }

        self.note = managedObject.note
    }
}
