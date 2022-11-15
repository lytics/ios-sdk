//
//  DataUploadRequestBuilder.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

import Foundation

struct DataUploadRequestBuilder {
    var requests: ([String: [any StreamEvent]]) throws -> [Request<DataUploadResponse>]
}

extension DataUploadRequestBuilder {
    static func live(apiKey: String, dryRun: Bool = false) -> Self {
        let encoder = JSONEncoder()
        let requestBuilder = RequestBuilder.live(apiKey: apiKey)

        return .init(
            requests: {
                try $0.reduce(into: [Request<DataUploadResponse>]()) { requests, element in
                    do {
                        var data = Data()
                        switch element.value.count {
                        case 0:
                            break
                        case 1:
                            let event = element.value.first!
                            data = try encoder.encode(event)
                        default:
                            data = try element.value.reduce(into: Data([.leftSquareBracket])) { data, value in
                                if data.count > 1 {
                                    data.append(.comma)
                                }
                                data.append(try encoder.encode(value))
                            }
                            data.append(.rightSquareBracket)
                        }

                        requests.append(
                            requestBuilder.dataUpload(
                                stream: element.key,
                                dryrun: dryRun,
                                data: data))
                    }
                }
            })
    }
}
