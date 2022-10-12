//
//  Operators.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

precedencegroup ForwardApplication {
    associativity: left
    higherThan: NilCoalescingPrecedence
}

infix operator |>: ForwardApplication

func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

func |> <A, B>(x: A, f: (A) throws -> B) throws -> B {
    return try f(x)
}

func |> <A, B>(x: A?, f: (A?) -> B?) -> B? {
    return f(x)
}

func |> <A, B>(x: A?, f: (A?) throws -> B?) throws -> B? {
    return try f(x)
}

func |> <A, B>(x: A?, f: (A) -> B?) -> B? {
    guard let x = x else {
        return nil
    }
    return f(x)
}

func |> <A, B>(x: A?, f: (A) throws -> B?) throws -> B? {
    guard let x = x else {
        return nil
    }
    return try f(x)
}

func |> <A, B>(x: A?, f: (A) -> B) -> B? {
    guard let x = x else {
        return nil
    }
    return f(x)
}

func |> <A, B>(x: A?, f: (A) throws -> B) throws -> B? {
    guard let x = x else {
        return nil
    }
    return try f(x)
}
