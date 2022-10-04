//
//  HeaderField+Values.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension HeaderField {
    static func authorization(_ token: String) -> Self {
        .init(name: "Authorization", value: token)
    }
}
