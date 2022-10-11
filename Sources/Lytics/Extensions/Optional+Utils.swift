//
//  Optional+Utils.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension Optional where Wrapped: RangeReplaceableCollection {

    /// Append a value to an existing collection or create one from that element.
    ///
    /// Usage:
    ///
    /// ```swift
    /// var maybeArray: [Int]?
    /// maybeArray.appendOrSet(1) // Optional([1])
    /// maybeArray.appendOrSet(2) // Optional([1, 2])
    /// ```
    ///
    /// - Parameter element: The element to append.
    mutating func appendOrSet<E>(_ element: E) where E == Wrapped.Element {
        switch self {
        case .some:
            self?.append(element)
        case .none:
            self = .some(Wrapped([element]))
        }
    }

    /// Unwrap a value and append it to an existing collection or create one from it.
    ///
    /// Usage:
    ///
    /// ```swift
    /// var maybeArray: [Int]?
    /// maybeArray.appendOrSet(1) // Optional([1])
    /// maybeArray.appendOrSet(nil) // Optional([1])
    /// ```
    ///
    /// - Parameter element: The element to append.
    mutating func appendOrSet<E>(_ element: E?) where E == Wrapped.Element {
        switch (self, element) {
        case (.some, .some(let element)):
            self?.append(element)
        case (.none, .some(let element)):
            self = .some(Wrapped([element]))
        default:
            return
        }
    }
}
