//
//  Uploading.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation

/// A type capable of uploading requests to the Lytics API.
protocol Uploading: Actor {

    /// Uploads requests to the Lytics API.
    /// - Parameter request: The requests to upload.
    func upload<T: Codable>(_ request: [Request<T>])

    /// Stores pending requests and cancels their upload tasks.
    func storeRequests()
}
