//
//  UserDefaults+Utils.swift
//
//  Created by Mathew Gacy on 10/20/22.
//

import Foundation

// MARK: - Read
extension UserDefaults {

    func bool(for key: UserDefaultsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func dictionary(for key: UserDefaultsKey) -> [String: Any]? {
        dictionary(forKey: key.rawValue)
    }

    func int64(for key: UserDefaultsKey) -> Int64 {
        object(forKey: key.rawValue) as? Int64 ?? 0
    }

    func integer(for key: UserDefaultsKey) -> Int {
        integer(forKey: key.rawValue)
    }

    func string(for key: UserDefaultsKey) -> String? {
        string(forKey: key.rawValue)
    }
}

// MARK: - Write
extension UserDefaults {

    func set(_ value: Bool, for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func set(_ value: [String: Any], for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func set(_ value: Int64, for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func set(_ value: Int, for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func set(_ value: String, for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }
}
