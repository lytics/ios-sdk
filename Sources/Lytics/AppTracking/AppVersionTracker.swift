//
//  AppVersionTracker.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

struct AppVersionTracker: Sendable {

    /// Tracked application events.
    enum AppVersionEvent {
        /// User installed app.
        case install(_ version: String)
        /// User updated app.
        case update(_ version: String)
    }

    var checkVersion: @Sendable () -> AppVersionEvent?
}

extension AppVersionTracker {
    static var live: AppVersionTracker {
        .init(
            checkVersion: {
                let lastVersion = UserDefaults.standard.string(for: .lastVersionNumber)

                let currentVersion = Bundle.main.releaseVersionNumber ?? Constants.defaultAppVersion
                UserDefaults.standard.set(currentVersion, for: .lastVersionNumber)

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
