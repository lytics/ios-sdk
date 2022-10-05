//
//  RequestPerforming.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

protocol RequestPerforming {
    func perform<T: RequestProtocol>(_ request: T) async throws -> Response<T.Resp>
}
