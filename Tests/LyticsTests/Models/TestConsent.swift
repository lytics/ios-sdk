//
//  TestConsent.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

import Foundation

struct TestConsent: Codable, Equatable {
    var document: String
    var timestamp: String
    var consented: Bool
}

extension TestConsent {
    static var user1: Self {
        .init(
            document: "gdpr_collection_agreement_v1",
            timestamp: "46236424246",
            consented: true)
    }
}
