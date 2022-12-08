//
//  URLEvent.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import AnyCodable
import Foundation

struct URLEvent: Codable, Equatable {
    let url: URL
    let options: [AnyCodable: AnyCodable]?
}
