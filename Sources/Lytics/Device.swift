//
//  Device.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation
import class UIKit.UIDevice

@usableFromInline
struct Device: Encodable, Equatable {

    /// The operating system version.
    var osVersion: String {
        UIDevice.current.systemVersion
    }

    /// The device model name.
    var name: String {
        UIDevice.current.name
    }

    @usableFromInline
    init() {}

    @usableFromInline
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.osVersion, forKey: .osVersion)
        try container.encode(self.name, forKey: .name)
    }

    private enum CodingKeys: CodingKey {
        case osVersion
        case name
    }
}
