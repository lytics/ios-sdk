//
//  RequestBuilder.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

/// A `RequestBuilder` builds requests for Lytics API endpoints.
struct RequestBuilder {
    private let apiToken: String
    private let collectionEndpoint: URL
    private let entityEndpoint: URL

    private var authHeader: HeaderField {
        .authorization(apiToken)
    }

    init(apiToken: String, collectionEndpoint: URL, entityEndpoint: URL) {
        self.apiToken = apiToken
        self.collectionEndpoint = collectionEndpoint
        self.entityEndpoint = entityEndpoint
    }

    /// Uploads event to API.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - dryrun: A Boolean value indicating whether an event should be processed.
    ///   - timestampField: The name of the column or field in file that contains event timestamp.
    ///   - filename: An identifier specifying the unique source of an individual event.
    ///   - data: The data to upload.
    /// - Returns: The request.
    func dataUpload(
        stream: String,
        dryrun: Bool? = nil,
        timestampField: String? = nil,
        filename: String? = nil,
        data: Data
    ) -> Request<DataUploadResponse> {
        var parameters: [QueryParameter]?
        parameters.appendOrSet(dryrun.flatMap(QueryParameter.dryrun))
        parameters.appendOrSet(timestampField.flatMap(QueryParameter.timestampField))
        parameters.appendOrSet(filename.flatMap(QueryParameter.filename))

        let url = collectionEndpoint.appendingPathComponent(stream, isDirectory: false)
        return post(url, data: data, parameters: parameters)
    }

    /// Fetches the attributes of and segments to which an entity belongs.
    /// - Parameters:
    ///   - table: The table.
    ///   - fieldName: The field name of identity.
    ///   - fieldVal: The field value of identity.
    ///   - fields: The fields to include.
    ///   - segments: A Boolean indicating whether the response should include segments to which the
    ///    entity belongs.
    ///   - meta: A Boolearn indicating whether the response should include Meta Fields.
    /// - Returns: The request.
    func entity(
        table: String,
        fieldName: String,
        fieldVal: String,
        fields: [String]? = nil,
        segments: Bool? = nil,
        meta: Bool? = nil
    ) -> Request<Entity> {
        var parameters: [QueryParameter]?
        parameters.appendOrSet(fields.flatMap(QueryParameter.fields))
        parameters.appendOrSet(segments.flatMap(QueryParameter.segments))
        parameters.appendOrSet(meta.flatMap(QueryParameter.meta))

        let url = entityEndpoint.appendingPathComponent("/\(table)/\(fieldName)/\(fieldVal)", isDirectory: false)
        return get(url, parameters: parameters)
    }
}

extension RequestBuilder {
    static func live(apiToken: String, configuration: LyticsConfiguration) -> Self {
        .init(
            apiToken: apiToken,
            collectionEndpoint: configuration.collectionEndpoint,
            entityEndpoint: configuration.entityEndpoint
        )
    }
}

private extension RequestBuilder {
    func get<T>(_ url: URL, parameters: [QueryParameter]? = nil, contentType: HeaderField.ContentType = .json) -> Request<T> {
        .init(method: .get, url: url, parameters: parameters, headers: [.contentType(contentType), authHeader])
    }

    func post<T>(_ url: URL, data: Data, parameters: [QueryParameter]? = nil, contentType: HeaderField.ContentType = .json) -> Request<T> {
        .init(method: .post, url: url, parameters: parameters, headers: [.contentType(contentType), authHeader], body: data)
    }
}
