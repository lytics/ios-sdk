//
//  URLEvent.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import AnyCodable
import Foundation

struct URLEvent: Codable, Equatable {
    var url: URL
    var options: [AnyCodable: AnyCodable]?
    var identifiers: [String: AnyCodable]?
}
