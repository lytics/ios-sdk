//
//  ShortcutEvent.swift
//
//  Created by Mathew Gacy on 12/8/22.
//

import AnyCodable
import Foundation
import class UIKit.UIApplicationShortcutItem

struct ShortcutEvent: Codable, Equatable {
    var localizedTitle: String
    var localizedSubtitle: String?
    var type: String
    var userInfo: [AnyCodable: AnyCodable]?
    var targetContentIdentifier: AnyCodable?
}

extension ShortcutEvent {
    init(_ shortcutItem: UIApplicationShortcutItem) {
        self.localizedTitle = shortcutItem.localizedTitle
        self.localizedSubtitle = shortcutItem.localizedSubtitle
        self.type = shortcutItem.type
        self.userInfo = Dictionary(shortcutItem.userInfo)
        self.targetContentIdentifier = shortcutItem.targetContentIdentifier.flatMap(AnyCodable.init)
    }
}
