//
//  UserActivityEvent.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import AnyCodable
import Foundation

struct UserActivityEvent: Codable, Equatable {
    var activityType: String
    var keywords: Set<String>
    var referrerURL: URL?
    var requiredUserInfoKeys: Set<String>?
    var targetContentIdentifier: String?
    var title: String?
    var userInfo: [AnyCodable: AnyCodable]?
    var webpageURL: URL?
    var identifiers: [String: AnyCodable]?
}

extension UserActivityEvent {
    init(_ userActivity: NSUserActivity, identifiers: [String: AnyCodable]? = nil) {
        self.activityType = userActivity.activityType
        self.keywords = userActivity.keywords
        self.referrerURL = userActivity.referrerURL
        self.requiredUserInfoKeys = userActivity.requiredUserInfoKeys
        self.targetContentIdentifier = userActivity.targetContentIdentifier
        self.title = userActivity.title
        self.userInfo = Dictionary(userActivity.userInfo)
        self.webpageURL = userActivity.webpageURL
        self.identifiers = identifiers
    }
}
