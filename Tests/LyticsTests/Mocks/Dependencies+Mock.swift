//
//  Dependencies+Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

@testable import Lytics
import Foundation

extension AppVersionTracker {
    static func mock(_ event: AppVersionEvent? = nil) -> Self {
        .init {
            event
        }
    }
}

extension DataUploadRequestBuilder {
    static var mock: Self {
        .init(requests: { _ in [] })
    }
}

extension LyticsLogger {
    static var mock: Self {
        .init(log: { _, _, _, _, _ in })
    }
}

extension UserSettings {
    static let optedInMock = Self(
        getOptIn: { true },
        setOptIn: { _ in })

    static let optedOutMock = Self(
        getOptIn: { false },
        setOptIn: { _ in })
}
