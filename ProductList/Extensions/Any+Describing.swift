//
//  Any+Describing.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 24.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import Foundation

extension CustomStringConvertible {

    var describingName: String {
        String(describing: type(of: self))
    }
}
