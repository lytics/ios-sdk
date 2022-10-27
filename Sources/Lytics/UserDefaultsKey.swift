//
//  UserDefaultsKey.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

/// Keys used to store data in `UserDefaults`.
enum UserDefaultsKey: String {

    /// Whether the user opted in to tracking.
    case didOptIn = "did_opt_in"

    /// Whether IDFA usage has been enabled.
    ///
    /// This is separate from the OS `ATTrackingManager.trackingAuthorizationStatus`.
    case idfaIsEnabled = "idfa_is_enabled"

    /// The most recent event timestamp.
    case lastEventTimestamp = "last_event_timestamp"

    /// The most recent release or version number.
    case lastVersionNumber = "last_version_number"

    /// The current user attributes.
    case userAttributes = "user_attributes"

    /// The current user identifiers.
    case userIdentifiers = "user_identifiers"
}
