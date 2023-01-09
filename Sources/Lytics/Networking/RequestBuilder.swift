//
//  RequestBuilder.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

/// A `RequestBuilder` builds requests for Lytics API endpoints.
struct RequestBuilder {

    enum Route: PathProvider {
        /// Path: `/collect/json/{stream}/`
        case dataUpload(String)
        /// Path: `/api/entity/{table}/{field}/{value}`.
        case personalization(table: String, field: String, value: String)

        var path: String {
            switch self {
            case let .dataUpload(stream):
                return "/collect/json/\(stream)"
            case let .personalization(table, field, value):
                return "/api/entity/\(table)/\(field)/\(value)"
            }
        }
    }

    private let baseURL: URL
    private let apiToken: String

    private var authHeader: HeaderField {
        .authorization(apiToken)
    }

    init(baseURL: URL, apiToken: String) {
        self.baseURL = baseURL
        self.apiToken = apiToken
    }

    /// Upload event to API.
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

        return post(.dataUpload(stream), data: data, parameters: parameters)
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

        return get(.personalization(table: table, field: fieldName, value: fieldVal), parameters: parameters)
    }
}

extension RequestBuilder {
    static func live(baseURL: URL, apiToken: String) -> Self {
        .init(baseURL: baseURL, apiToken: apiToken)
    }
}

private extension RequestBuilder {
    func url(for route: Route) -> URL {
        baseURL.appending(route)
    }

    func get<T>(_ route: Route, parameters: [QueryParameter]? = nil) -> Request<T> {
        .init(method: .get, url: url(for: route), headers: [authHeader])
    }

    func post<T>(_ route: Route, data: Data, parameters: [QueryParameter]? = nil, contentType: HeaderField.ContentType = .json) -> Request<T> {
        .init(method: .post, url: url(for: route), parameters: parameters, headers: [.contentType(contentType), authHeader], body: data)
    }
}
