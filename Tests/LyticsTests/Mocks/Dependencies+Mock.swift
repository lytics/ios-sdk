//
//  Dependencies+Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

@testable import Lytics
import Foundation

extension DataUploadRequestBuilder {
    static var mock: Self {
        .init(requests: { _ in [] })
    }
}

extension LyticsLogger {
    static var mock: Self {
        .init(log: { _, _, _, _, _ in })
    }
}
