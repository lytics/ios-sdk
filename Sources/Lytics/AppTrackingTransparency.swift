//
//  AppTrackingTransparency.swift
//
//  Created by Mathew Gacy on 10/24/22.
//

import AdSupport
import AppTrackingTransparency

@usableFromInline
struct AppTrackingTransparency {
    @usableFromInline var authorizationStatus: () -> ATTrackingManager.AuthorizationStatus
    @usableFromInline var idfa: () -> String?
    @usableFromInline var requestAuthorization: () async -> Bool
}

extension AppTrackingTransparency {
    @usableFromInline static var live: Self {
        .init(
            authorizationStatus: {
                ATTrackingManager.trackingAuthorizationStatus
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
//                    userDefaults.set(true, for: .idfaIsEnabled)
                    return true
                case .notDetermined, .restricted, .denied:
                    return false
                @unknown default:
                    return false
                }
            })
    }
}