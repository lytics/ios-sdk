//
//  AppTrackingTransparency.swift
//
//  Created by Mathew Gacy on 10/24/22.
//

import AdSupport
import AppTrackingTransparency

struct AppTrackingTransparency {
    var authorizationStatus: () -> ATTrackingManager.AuthorizationStatus
    var disableIDFA: () -> Void
    var enableIDFA: () -> Void
    var idfa: () -> String?
    var requestAuthorization: () async -> Bool
}

extension AppTrackingTransparency {
    static var live: Self {
        let userDefaults = UserDefaults.standard

        return AppTrackingTransparency(
            authorizationStatus: {
                ATTrackingManager.trackingAuthorizationStatus
            },
            disableIDFA: {
                userDefaults.set(false, for: .idfaIsEnabled)
            },
            enableIDFA: {
                userDefaults.set(true, for: .idfaIsEnabled)
            },
            idfa: {
                guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
                    return nil
                }

                return ASIdentifierManager.shared()
                    .advertisingIdentifier
                    .uuidString
            },
            requestAuthorization: {
                let status = await ATTrackingManager.requestTrackingAuthorization()
                switch status {
                case .authorized:
                    userDefaults.set(true, for: .idfaIsEnabled)
                    return true
                case .denied, .notDetermined, .restricted:
                    userDefaults.set(false, for: .idfaIsEnabled)
                    return false
                @unknown default:
                    return false
                }
            }
        )
    }
}
