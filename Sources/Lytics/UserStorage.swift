//
//  UserStorage.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation

struct UserStorage {
    var attributes: () -> [String: Any]?
    var identifiers: () -> [String: Any]?
    var storeAttributes: ([String: Any]) -> Void
    var storeIdentifiers: ([String: Any]) -> Void
}

extension UserStorage {
    static var live: Self {
        let userDefaults = UserDefaults.standard

        return .init(
            attributes: {
                userDefaults.dictionary(for: .userAttributes)
            },
            identifiers: {
                userDefaults.dictionary(for: .userIdentifiers)
            },
            storeAttributes: { attributes in
                userDefaults.set(attributes, for: .userAttributes)
            },
            storeIdentifiers: { identifiers in
                userDefaults.set(identifiers, for: .userIdentifiers)
            })
    }

    #if DEBUG
    static let mock = UserStorage(
        attributes: { [:] },
        identifiers: { [:] },
        storeAttributes: { _ in },
        storeIdentifiers: { _ in })
    #endif
}
