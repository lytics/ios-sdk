//
//  HeaderField+Values.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension HeaderField {

    /// A type-safe representation of the value of a content type header field.
    enum ContentType: String {
        case json = "application/json"
        case plainText = "text/plain"
    }

    /// Returns a content type header field.
    /// - Parameter contentType: The content type.
    /// - Returns: A content type header field.
    static func contentType(_ contentType: ContentType) -> Self {
        .init(name: "Content-Type", value: contentType.rawValue)
    }

    /// Returns an authorization header field.
    /// - Parameter token: An API token.
    /// - Returns: An authorization header field.
    static func authorization(_ token: String) -> Self {
        .init(name: "Authorization", value: token)
    }
}
