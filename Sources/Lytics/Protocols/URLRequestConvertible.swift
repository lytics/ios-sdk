//
//  URLRequestConvertible.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

/// A type that can convert itself into a `URLRequest`.
protocol URLRequestConvertible {

    /// Returns a `URLRequest` instance.
    func asURLRequest() throws -> URLRequest
}
