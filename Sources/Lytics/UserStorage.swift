//
//  UserStorage.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation

struct UserStorage {
    var attributes: () -> [String: Any]?
    var identifiers: () -> [String: Any]?
    var storeAttributes: ([String: Any]?) -> Void
    var storeIdentifiers: ([String: Any]?) -> Void
}

extension UserStorage {
    static func live(userDefaults: UserDefaults = .standard) -> Self {
        .init(
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
            }
        )
    }

    #if DEBUG
        static func mock(
            attributes: @escaping () -> [String: Any]? = { [:] },
            identifiers: @escaping () -> [String: Any]? = { nil },
            storeAttributes: @escaping ([String: Any]?) -> Void = { _ in },
            storeIdentifiers: @escaping ([String: Any]?) -> Void = { _ in }
        ) -> UserStorage {
            .init(
                attributes: attributes,
                identifiers: identifiers,
                storeAttributes: storeAttributes,
                storeIdentifiers: storeIdentifiers
            )
        }
    #endif
}
