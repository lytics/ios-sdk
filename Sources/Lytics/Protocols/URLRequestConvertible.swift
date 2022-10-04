//
//  URLRequestConvertible.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

protocol URLRequestConvertible {
    /// Returns a `URLRequest` instance.
    func asURLRequest() throws -> URLRequest
}
