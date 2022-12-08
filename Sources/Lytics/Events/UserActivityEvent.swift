//
//  UserActivityEvent.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import AnyCodable
import Foundation

struct UserActivityEvent: Codable, Equatable {
    var activityType: String
    var title: String?
    var requiredUserInfoKeys: Set<String>?
    var userInfo: [AnyCodable: AnyCodable]?
    var targetContentIdentifier: String?
    var keywords: Set<String>
    var webpageURL: URL?
    var referrerURL: URL?
}

extension UserActivityEvent {
    init(_ userActivity: NSUserActivity) {
        self.activityType = userActivity.activityType
        self.title = userActivity.title
        self.requiredUserInfoKeys = userActivity.requiredUserInfoKeys
        self.userInfo = Dictionary(userActivity.userInfo)
        self.targetContentIdentifier = userActivity.targetContentIdentifier
        self.keywords = userActivity.keywords
        self.webpageURL = userActivity.webpageURL
        self.referrerURL = userActivity.referrerURL
    }
}
