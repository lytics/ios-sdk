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
    var idfa: @Sendable () -> String?
    var requestAuthorization: () async -> Bool
}

extension AppTrackingTransparency {
    static var live: Self {
        AppTrackingTransparency(
            authorizationStatus: {
                ATTrackingManager.trackingAuthorizationStatus
            },
            disableIDFA: {
                UserDefaults.standard.set(false, for: .idfaIsEnabled)
            },
            enableIDFA: {
                UserDefaults.standard.set(true, for: .idfaIsEnabled)
            },
            idfa: {
                guard UserDefaults.standard.bool(for: .idfaIsEnabled), ATTrackingManager.trackingAuthorizationStatus == .authorized else {
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
                    UserDefaults.standard.set(true, for: .idfaIsEnabled)
                    return true
                case .denied, .notDetermined, .restricted:
                    UserDefaults.standard.set(false, for: .idfaIsEnabled)
                    return false
                @unknown default:
                    return false
                }
            }
        )
    }
}
