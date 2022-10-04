//
//  DataUploadResponse.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

struct DataUploadResponse: Codable, Equatable {

    struct ResponseData: Codable, Equatable {
        let messageCount: Int
        let rejectedCount: Int
        let contentType: String?
        let dropErrors: Bool?
        let dryrun: Bool?
        let timestampField: String?
        let filename: String?

        private enum CodingKeys: String, CodingKey {
            case messageCount = "message_count"
            case rejectedCount = "rejected_count"
            case contentType = "content-type"
            case dropErrors = "droperrors"
            case dryrun
            case timestampField = "timestamp_field"
            case filename
        }
    }

    let status: Int
    let message: String
    let data: ResponseData
}
