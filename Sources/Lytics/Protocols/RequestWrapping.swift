//
//  RequestWrapping.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

/// A type that wraps a request.
protocol RequestWrapping<Resp>: Codable {
    /// The type of the wrapped request's response.
    associatedtype Resp: Codable

    /// A unique value identifying the wrapped request.
    var id: UUID { get }

    /// The wrapped request.
    var request: Request<Resp> { get }

    /// A count of attempts to upload the wrapped requeust.
    var retryCount: Int { get set }

    /// The task to upload the wrapped request.
    var uploadTask: Task<Void, Never>? { get set }

    /// Cancels the upload task.
    func cancel()
}
