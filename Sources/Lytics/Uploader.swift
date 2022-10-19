//
//  Uploader.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

actor Uploader: Uploading {
    private let logger: LyticsLogger
    private let decoder: JSONDecoder
    private let requestPerformer: RequestPerforming

    init(
        logger: LyticsLogger,
        decoder: JSONDecoder = .init(),
        requestPerformer: RequestPerforming
    ) {
        self.logger = logger
        self.decoder = decoder
        self.requestPerformer = requestPerformer
    }

    /// Uploads requests to the Lytics API.
    /// - Parameter request: The requests to upload.
    func upload<T: Codable>(_ request: [Request<T>]) {
        // ...
    }
}

extension Uploader {
    static func live(
        logger: LyticsLogger
    ) -> Uploader {
        .init(
            logger: logger,
            requestPerformer: URLSession.live)
    }
}
