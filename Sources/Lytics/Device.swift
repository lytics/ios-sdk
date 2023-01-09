//
//  Device.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation
import UIKit

@usableFromInline
struct Device: Encodable, Equatable {

    /// A UUID that uniquely identifies a device to the app’s vendor.
    var identifierForVendor: UUID? {
        UIDevice.current.identifierForVendor
    }

    /// The device model name.
    var name: String {
        UIDevice.current.name
    }

    /// The physical orientation of the device.
    var orientation: String {
        String(describing: UIDevice.current.orientation)
    }

    /// The operating system version.
    var osVersion: String {
        UIDevice.current.systemVersion
    }

    /// The style of interface used on the device.
    var userInterfaceIdiom: String {
        String(describing: UIDevice.current.userInterfaceIdiom)
    }

    @usableFromInline
    init() {}

    @usableFromInline
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(identifierForVendor, forKey: .identifierForVendor)
        try container.encode(name, forKey: .name)
        try container.encode(orientation, forKey: .orientation)
        try container.encode(osVersion, forKey: .osVersion)
        try container.encode(userInterfaceIdiom, forKey: .userInterfaceIdiom)
    }

    private enum CodingKeys: CodingKey {
        case identifierForVendor
        case name
        case orientation
        case osVersion
        case userInterfaceIdiom
    }
}
