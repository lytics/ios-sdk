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

// MARK: - Synchronous

func |> <A, B>(x: A, f: (A) -> B) -> B {
    f(x)
}

func |> <A, B>(x: A, f: (A) throws -> B) throws -> B {
    try f(x)
}

func |> <A, B>(x: A?, f: (A?) -> B?) -> B? {
    f(x)
}

func |> <A, B>(x: A?, f: (A?) throws -> B?) throws -> B? {
    try f(x)
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

// MARK: - Asynchronous

func |> <A, B>(x: A, f: (A) async -> B) async -> B {
    await f(x)
}

func |> <A, B>(x: A, f: (A) async throws -> B) async throws -> B {
    try await f(x)
}

func |> <A, B>(x: A?, f: (A?) async -> B?) async -> B? {
    await f(x)
}

func |> <A, B>(x: A?, f: (A?) async throws -> B?) async throws -> B? {
    try await f(x)
}

func |> <A, B>(x: A?, f: (A) async -> B?) async -> B? {
    guard let x = x else {
        return nil
    }
    return await f(x)
}

func |> <A, B>(x: A?, f: (A) async throws -> B?) async throws -> B? {
    guard let x = x else {
        return nil
    }
    return try await f(x)
}

func |> <A, B>(x: A?, f: (A) async -> B) async -> B? {
    guard let x = x else {
        return nil
    }
    return await f(x)
}

func |> <A, B>(x: A?, f: (A) async throws -> B) async throws -> B? {
    guard let x = x else {
        return nil
    }
    return try await f(x)
}
