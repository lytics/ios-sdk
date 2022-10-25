//
//  DemoConsent.swift
//
//  Created by Mathew Gacy on 10/5/22.
//

import Foundation

struct DemoConsent: Codable, Equatable {
    var documents: [String]
    var timestamp: String?
    var consented: Bool
}
