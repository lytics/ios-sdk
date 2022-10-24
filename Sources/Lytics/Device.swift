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
        return UIDevice.current.name
    }

    @usableFromInline
    init() {}
}
