//
//  IdentityEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

@usableFromInline
struct IdentityEvent<I: Encodable, A: Encodable>: Encodable {
    var identifiers: I?
    var attributes: A?

    @usableFromInline
    init(
        identifiers: I? = nil,
        attributes: A? = nil
    ) {
        self.identifiers = identifiers
        self.attributes = attributes
    }
}

// MARK: Equatable
extension IdentityEvent: Equatable where I: Equatable, A: Equatable {}
