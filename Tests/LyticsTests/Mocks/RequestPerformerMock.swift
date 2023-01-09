//
//  RequestPerformerMock.swift
//
//  Created by Mathew Gacy on 1/2/23.
//

import Foundation
@testable import Lytics
import XCTest

struct RequestPerformerMock<Resp>: RequestPerforming {
    let handler: (Request<Resp>) throws -> Response<Resp>

    func perform<R>(_ request: Request<R>) async throws -> Response<R> {
        guard let request = request as? Request<Resp>,
              let response = try handler(request) as? Response<R> else {
            throw TestError(message: "Request performer received unexpected type: \(type(of: request))")
        }

        return response
    }
}

extension RequestPerformerMock {
    static var failing: Self {
        .init { _ in
            XCTFail("Request sent unexpectedly")
            throw TestError(message: "Request sent")
        }
    }

    static var clientError: Self {
        .init { _ in
            throw NetworkError.clientError(
                Mock.httpResponse(400))
        }
    }

    static var serverError: Self {
        .init { _ in
            throw NetworkError.serverError(
                Mock.httpResponse(500))
        }
    }
}
