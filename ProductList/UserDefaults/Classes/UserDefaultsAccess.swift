//
//  UserDefaultsAccess.swift
//  Activity
//
//  Created by Vladislav Kalugin on 16.03.2020.
//  Copyright © 2018 ActivityIT. All rights reserved.
//

import Foundation

final class UserDefaultsAccess {

    static let shared = UserDefaultsAccess()

    private init() { }

    private let accessQueue = DispatchQueue(label: "User Defaults Synchronize Queue")

    public func get<T: Codable>(_ type: T.Type, key: String) -> T? {
        self.accessQueue.sync {
            if let data = UserDefaults.standard.value(forKey: key) as? Data,
                let unarchivedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T {
                return unarchivedData
            } else {
                return nil
            }
        }
    }

    public func set<T: Codable>(value: T, key: String, requiringSecureCoding: Bool = true) {
        self.accessQueue.sync {
            let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: requiringSecureCoding)

            UserDefaults.standard.set(archivedData, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    public func remove(key: String) {
        self.accessQueue.sync {
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}
