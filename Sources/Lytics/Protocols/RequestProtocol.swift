//
//  RequestProtocol.swift
//
//  Created by Mathew Gacy on 10/4/22.
//

import Foundation

protocol RequestProtocol<Resp> {
    associatedtype Resp: Decodable

    func asURLRequest() throws -> URLRequest
}
