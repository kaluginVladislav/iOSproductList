//
//  String+Localization.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 15.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import Foundation

extension String {

    var localized: String {
        return NSLocalizedString(self, tableName: "Localization", value: self, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        return String(format: self.localized, arguments: args)
    }
}
