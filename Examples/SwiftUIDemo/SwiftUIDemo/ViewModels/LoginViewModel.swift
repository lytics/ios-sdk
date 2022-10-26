//
//  LoginViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import Lytics

final class LoginViewModel: ObservableObject {
    @Published var email: String
    @Published var password: String

    var loginIsEnabled: Bool {
        email.isNotEmpty && password.isNotEmpty
    }

    init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
    }

    func login() {
        guard loginIsEnabled else {
            return
        }

        Lytics.shared.identify(
            identifiers: DemoIdentity(email: email))
    }

    func forgotPassword() {
        print("\(#function)")
    }
}
