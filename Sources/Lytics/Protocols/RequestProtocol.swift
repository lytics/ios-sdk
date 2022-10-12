//
//  RequestProtocol.swift
//
//  Created by Mathew Gacy on 10/4/22.
//

import Foundation

/// A type that can convert itself into a `URLRequest` with a `Decodable` response value.
protocol RequestProtocol<Resp>: URLRequestConvertible {
    associatedtype Resp: Decodable
}
