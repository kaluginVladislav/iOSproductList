//
//  UserDefaultsCoder.swift
//  Activity
//
//  Created by Vladislav Kalugin on 16.03.2020.
//  Copyright © 2018 ActivityIT. All rights reserved.
//

import Foundation

final class UserDefaultsCoderItem<T: Codable>: Codable {

    enum CodingKeys: CodingKey {

        case item

    }

    let item: T?

    init(_ item: T?) {
        self.item = item
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        item = try container.decode(T.self, forKey: .item)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(item, forKey: .item)
    }
}

final class UserDefaultsCoder {

    static let shared = UserDefaultsCoder()

    private init() { }

    public func get<T: Codable>(_ type: T.Type, key: String) -> T? {
        if let data = UserDefaultsAccess.shared.get(Data.self, key: key),
            let decoder = try? JSONDecoder().decode(UserDefaultsCoderItem<T>.self, from: data) {
            return decoder.item
        } else {
            return nil
        }
    }

    public func set<T: Codable>(value: T?, key: String, requiringSecureCoding: Bool = true) {
        let item = UserDefaultsCoderItem(value)

        if let encoded = try? JSONEncoder().encode(item) {
            UserDefaultsAccess.shared.set(value: encoded, key: key, requiringSecureCoding: requiringSecureCoding)
        }
    }

    public func remove(key: String) {
        UserDefaultsAccess.shared.remove(key: key)
    }
}
