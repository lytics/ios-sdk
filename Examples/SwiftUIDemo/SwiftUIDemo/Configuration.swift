//
//  Configuration.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 11/16/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

fileprivate enum Configuration {
    enum Error: Swift.Error {
        case invalidValue
        case missingKey
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else {
                fallthrough
            }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum Secrets {
    static var apiToken: String {
        try! Configuration.value(for: "API_TOKEN")
    }
}
