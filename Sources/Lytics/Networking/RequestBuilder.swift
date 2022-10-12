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

        var path: String {
            switch self {
            case .dataUpload(let stream):
                return "/collect/json/\(stream)"
            }
        }
    }

    private let baseURL: URL
    private let apiKey: String

    private var authHeader: HeaderField {
        .authorization(apiKey)
    }

    init(baseURL: URL, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
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

        return post(.dataUpload(stream), data: data)
    }
}

private extension RequestBuilder {
    func url(for route: Route) -> URL {
        baseURL.appending(route)
    }

    func get<T>(_ route: Route, parameters: [QueryParameter]? = nil) -> Request<T> {
        .init(method: .get, url: url(for: route), headers: [authHeader])
    }

    func post<T>(_ route: Route, data: Data, contentType: HeaderField.ContentType = .json) -> Request<T> {
        .init(method: .post, url: url(for: route), headers: [.contentType(contentType), authHeader], body: data)
    }
}
