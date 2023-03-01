//
//  Primitive.swift
//
//  Created by Mathew Gacy on 2/28/23.
//

import Foundation

/// A class of types whose instances are primitive values.
protocol Primitive: Codable {}

extension Array: Primitive where Element: Primitive {}
extension Bool: Primitive {}
extension Date: Primitive {}
extension Double: Primitive {}
extension Float: Primitive {}
extension Int16: Primitive {}
extension Int32: Primitive {}
extension Int64: Primitive {}
extension Int8: Primitive {}
extension Int: Primitive {}
extension String: Primitive {}
extension UInt16: Primitive {}
extension UInt32: Primitive {}
extension UInt64: Primitive {}
extension UInt8: Primitive {}
extension UInt: Primitive {}
extension URL: Primitive {}
