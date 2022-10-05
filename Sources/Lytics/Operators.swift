//
//  Operators.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

// swiftlint:disable identifier_name
precedencegroup ForwardApplication {
    associativity: left
    higherThan: NilCoalescingPrecedence
}

infix operator |>: ForwardApplication

public func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

public func |> <A, B>(x: A, f: (A) throws -> B) throws -> B {
    return try f(x)
}

public func |> <A, B>(x: A?, f: (A?) -> B?) -> B? {
    return f(x)
}

public func |> <A, B>(x: A?, f: (A?) throws -> B?) throws -> B? {
    return try f(x)
}

public func |> <A, B>(x: A?, f: (A) -> B?) -> B? {
    guard let x = x else {
        return nil
    }
    return f(x)
}

public func |> <A, B>(x: A?, f: (A) throws -> B?) throws -> B? {
    guard let x = x else {
        return nil
    }
    return try f(x)
}

public func |> <A, B>(x: A?, f: (A) -> B) -> B? {
    guard let x = x else {
        return nil
    }
    return f(x)
}

public func |> <A, B>(x: A?, f: (A) throws -> B) throws -> B? {
    guard let x = x else {
        return nil
    }
    return try f(x)
}
