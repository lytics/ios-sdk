//
//  Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import AnyCodable
import Foundation
@testable import Lytics

enum Mock {
    static let apiToken = "at.xxxx"

    static let consentEvent = ConsentEvent(
        identifiers: User1.identifiers,
        attributes: User1.attributes,
        consent: TestConsent.user1
    )

    static let dataUploadResponse = decode(DataUploadResponse.self, from: dataUploadResponseJSON)

    static let entity = decode(Entity.self, from: entityJSON)

    static let event = Event(
        identifiers: User1.identifiers,
        properties: TestCart.user1
    )

    static let identityEvent = IdentityEvent(
        identifiers: TestIdentifiers.user1,
        attributes: TestAttributes.user1
    )

    static let millisecond: Millisecond = 1_600_000_000_000

    static let request = Request<DataUploadResponse>(
        method: .post,
        url: url
    )

    static let url = URL(string: "https://api.lytics.io/collect/json/stream")!

    static let user = LyticsUser(identifiers: User1.anyIdentifiers, attributes: User1.anyAttributes)

    static let uuidString = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"

    static var uuid: UUID {
        .init(uuidString: uuidString)!
    }
}

extension Mock {
    static func containerJSON<R: Codable>(response: R.Type, idStrings: [String]) -> String {
        func request(_ idString: String) -> String {
            """
            "{\\"id\\":\\"\(idString)\\",\\"request\\":{\\"method\\":\\"POST\\",\\"url\\":\\"https:\\\\\\/\\\\\\/api.lytics.io\\\\\\/collect\\\\\\/json\\\\\\/stream\\"}}"
            """
        }

        let typeString = _mangledTypeName(Uploader.PendingRequest<R>.self) ?? ""
        let elements = idStrings
            .map { "\"\(typeString)\",\(request($0))" }
            .joined(separator: ",")

        return "[\(elements)]"
    }

    static func httpResponse(
        _ statusCode: Int = 200,
        headerFields: [String: String]? = nil
    ) -> HTTPURLResponse {
        .init(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headerFields
        )!
    }

    static func payload<E: Encodable>(
        stream: String = Stream.one,
        timestamp: Millisecond = Timestamp.one,
        sessionDidStart: Int? = nil,
        name: String = Name.one,
        event: E
    ) -> Payload<E> {
        .init(
            stream: stream,
            timestamp: timestamp,
            sessionDidStart: sessionDidStart,
            name: name,
            event: event
        )
    }

    static func payloadDictionary(
        stream: String = Stream.one,
        timestamp: Millisecond = Timestamp.one,
        sessionDidStart: Int? = nil,
        name: String? = Name.one
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "stream": stream,
            "_ts": timestamp
        ]

        if let sessionDidStart {
            dict["_sesstart"] = sessionDidStart
        }

        if let name {
            dict["name"] = name
        }

        return dict
    }

    static func consentEventDictionary(
        payload: inout [String: Any],
        identifiers: [String: Any]? = nil,
        attributes: [String: Any]? = nil,
        consent: [String: Any]? = nil
    ) -> [String: Any] {
        payload["identifiers"] = identifiers
        payload["attributes"] = attributes
        payload["consent"] = consent
        return payload
    }

    static func eventDictionary(
        payload: inout [String: Any],
        identifiers: [String: Any]? = nil,
        properties: [String: Any]? = nil
    ) -> [String: Any] {
        payload["identifiers"] = identifiers
        payload["properties"] = properties
        return payload
    }

    static func identityEventDictionary(
        payload: inout [String: Any],
        identifiers: [String: Any]? = nil,
        attributes: [String: Any]? = nil
    ) -> [String: Any] {
        payload["identifiers"] = identifiers
        payload["attributes"] = attributes
        return payload
    }
}

private extension Mock {
    static func decode<T: Decodable>(_ type: T.Type, from jsonString: String) -> T {
        try! JSONDecoder().decode(type, from: jsonString.data(using: .utf8)!)
    }

    static let dataUploadResponseJSON = """
    {\"status\":200,\"message\":\"Message\",\"data\":{\"rejected_count\":0,\"message_count\":1}}
    """

    static let entityJSON = """
    {"data":{"_created":"2023-01-08T19:59:01.332454501Z","_cust_sz":"222","_id":"5339bac0-f776-5cca-b812-ded656bccc07","_internal_sz":"161","_last_scored":"2023-01-10T08:46:48.126014915Z","_modified":"2023-01-08T19:59:01.332454501Z","_num_aliases":"2","_num_conflicts":"0","_num_days":"1","_num_events":"1","_num_streams":"1","_segs":[{"k":"63e961c3ebcf9e9447a27e946587f50c","in":"2023-01-08T19:59:07.345909753Z","out":"2222-02-02T22:22:22.000000022Z"}],"_split":"34","_split2":"98","_streamnames":["default"],"_total_sz":"383","_uid":"\(uuidString)","_uids":["\(uuidString)"],"age":"21","cell":"4808675309","channels":["web"],"city":"Phoenix","company":["Acme Corp"],"country":"US","email":"\(User1.email)","first_name":"\(User1.firstName)","firstvisit_ts":"2023-01-08T19:59:01.332Z","gender":"Female","hourly":{"19":1},"hourofweek":{"19":1},"last_active_ts":"2023-01-08T19:59:01.332Z","last_channel_activities":{"web":"2023-01-08T19:59:01.332Z"},"last_name":"\(User1.lastName)","lastvisit_ts":"2023-01-08T19:59:01.332Z","name":"\(User1.firstName) \(User1.lastName)","origin":"somewhere","score_consistency":"0","score_frequency":"99","score_intensity":"0","score_maturity":"0","score_momentum":"100","score_propensity":"7","score_quantity":"0","score_recency":"98","score_volatility":"0","state":"AZ","title":\(User1.titles),"zip":"85226"},"message":"success","meta":{"by_fields":["_uids","email"],"conflicts":null,"format":"json","name":"user"},"status":200}
    """
}
