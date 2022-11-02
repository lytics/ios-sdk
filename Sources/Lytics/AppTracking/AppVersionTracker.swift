//
//  AppVersionTracker.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

struct AppVersionTracker {

    /// Tracked application events.
    enum AppVersionEvent {
        /// User installed app.
        case install(_ version: String)
        /// User updated app.
        case update(_ version: String)
    }

    var checkVersion: () -> AppVersionEvent?
}

extension AppVersionTracker {
    static var live: AppVersionTracker {
        let defaults = UserDefaults.standard

        return .init(
            checkVersion: {
                let lastVersion = defaults.string(for: .lastVersionNumber)

                let currentVersion = Bundle.main.releaseVersionNumber ?? "0.0"
                defaults.set(currentVersion, for: .lastVersionNumber)

                if lastVersion == nil {
                    return .install(currentVersion)
                } else if currentVersion != lastVersion {
                    return .update(currentVersion)
                } else {
                    return nil
                }
            })
    }
}
