//
//  ProfileViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import Lytics

@MainActor
final class ProfileViewModel:  ObservableObject {
    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }

    @Published private(set) var userJSON: String

    init(userJSON: String = "") {
        self.userJSON = userJSON
    }

    func getUser() async {
        do {
            let userModel = try await Lytics.shared.getProfile()
            let userData = try Self.encoder.encode(userModel)
            userJSON = String(decoding: userData, as: UTF8.self)
        } catch {
            print("Error encoding user model: \(error)")
        }
    }
}
