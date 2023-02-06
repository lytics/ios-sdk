//
//  URLEvent.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import AnyCodable
import Foundation
import class UIKit.UIApplication

struct URLEvent: Codable, Equatable {
    var url: URL
    var options: [String: AnyCodable]?
    var identifiers: [String: AnyCodable]?
}

extension URLEvent {
    init(
        url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]? = nil,
        identifiers: [String: AnyCodable]? = nil
    ) {
        self.url = url
        self.options = options != nil ? Dictionary(uniqueKeysWithValues: options!.map { ($0.rawValue, AnyCodable($1)) }) : nil
        self.identifiers = identifiers
    }
}
