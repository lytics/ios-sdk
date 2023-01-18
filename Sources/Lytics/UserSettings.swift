//
//  UserSettings.swift
//
//  Created by Mathew Gacy on 10/24/22.
//

import Foundation

struct UserSettings {
    var getOptIn: () -> Bool
    var setOptIn: (Bool) -> Void
}

extension UserSettings {
    static func live(userDefaults: UserDefaults = .standard) -> Self {
        .init(
            getOptIn: {
                userDefaults.bool(for: .didOptIn)
            },
            setOptIn: { value in
                userDefaults.set(value, for: .didOptIn)
            }
        )
    }
}
