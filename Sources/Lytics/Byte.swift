//
//  Byte.swift
//
//  Created by Mathew Gacy on 10/20/22.
//

import Foundation

/// An 8-bit unsigned integer.
public typealias Byte = UInt8

/// An array of 8-bit unsigned integers.
public typealias Bytes = [Byte]

/// Adds control character conveniences to `Byte`.
extension Byte {
    /// '\n'
    public static let newLine: Byte = 0xA

    /// ' '
    public static let space: Byte = 0x20

    /// ,
    public static let comma: Byte = 0x2C

    /// [
    public static let leftSquareBracket: Byte = 0x5B

    /// ]
    public static let rightSquareBracket: Byte = 0x5D
}

extension Byte {
    /// Returns the `String` representation of this `Byte` (unicode scalar).
    public var string: String {
        String(Character(Unicode.Scalar(self)))
    }
}
