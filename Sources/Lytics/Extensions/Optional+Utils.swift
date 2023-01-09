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
        case let (.some, .some(element)):
            self?.append(element)
        case let (.none, .some(element)):
            self = .some(Wrapped([element]))
        default:
            return
        }
    }
}

extension Optional where Wrapped == String {

    /// Returns the unwrapped, non-empty value, falling back to the given default value if there isn't one.
    /// - Parameter defaultValue: The default value to use if there is not a wrapped value or it is empty.
    /// - Returns: The unwrapped, non-empty value; otherwise `defaultValue`.
    func nonEmpty(default defaultValue: String) -> String {
        switch self {
        case let .some(value):
            return value.isNotEmpty ? value : defaultValue
        case .none:
            return defaultValue
        }
    }
}

public extension Optional where Wrapped == Never {

    /// A convenience member to specify an `Optional<Never>.none` value.
    static let never: Self = .none
}
