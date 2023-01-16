//
//  EntityIdentifier.swift
//
//  Created by Mathew Gacy on 1/16/23.
//

import Foundation

/// A field name and value used to identify an entity.
public struct EntityIdentifier: Equatable {

    /// The name of the identity field.
    public var name: String

    /// The value of hte identity field.
    public var value: String

    /// Creates an entity identifier.
    /// - Parameters:
    ///   - name: The name of the identity field.
    ///   - value: The value of hte identity field.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
