//
//  AppEventProvider.swift
//
//  Created by Mathew Gacy on 10/23/22.
//

import AnyCodable
import Foundation

struct AppEventProvider {
    typealias Name = String

    struct AppUpdate: Codable {
        let version: String
    }

    private let identifiers: @Sendable () async -> [String: AnyCodable]

    init(identifiers: @escaping @Sendable () async -> [String: AnyCodable]) {
        self.identifiers = identifiers
    }
}

extension AppEventProvider {
    func appBackground() async -> (Name, Event<Never>) {
        (
            EventNames.appBackground,
            Event(
                identifiers: await identifiers(),
                properties: .never
            )
        )
    }

    func appInstall() async -> (Name, Event<Never>) {
        (
            EventNames.appInstall,
            Event(
                identifiers: await identifiers(),
                properties: .never
            )
        )
    }

    func appOpen() async -> (Name, Event<Never>) {
        (
            EventNames.appOpen,
            Event(
                identifiers: await identifiers(),
                properties: .never
            )
        )
    }

    func appUpdate(version: String) async -> (Name, Event<AppUpdate>) {
        (
            EventNames.appUpdate,
            Event(
                identifiers: await identifiers(),
                properties: AppUpdate(version: version)
            )
        )
    }
}
