//
//  Entity.swift
//
//  Created by Mathew Gacy on 1/4/23.
//

import AnyCodable
import Foundation

struct Entity: Codable, Equatable {

    struct Meta: Codable, Equatable {
        var byFields: [String]
        var format: String
        var name: String

        init(
            byFields: [String],
            format: String,
            name: String
        ) {
            self.byFields = byFields
            self.format = format
            self.name = name
        }

        private enum CodingKeys: String, CodingKey {
            case byFields = "by_fields"
            case format
            case name
        }
    }

    var data: AnyCodable
    var message: String
    var meta: Meta?
    var status: Int

    init(
        data: AnyCodable,
        message: String,
        meta: Meta? = nil,
        status: Int
    ) {
        self.data = data
        self.message = message
        self.meta = meta
        self.status = status
    }
}
