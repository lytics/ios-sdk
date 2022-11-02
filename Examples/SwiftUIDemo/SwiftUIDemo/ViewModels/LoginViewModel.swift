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
    var onComplete: () -> Void

    var loginIsEnabled: Bool {
        email.isNotEmpty && password.isNotEmpty
    }

    init(
        email: String = "",
        password: String = "",
        onComplete: @escaping () -> Void = {}
    ) {
        self.email = email
        self.password = password
        self.onComplete = onComplete
    }

    func login() {
        guard loginIsEnabled else {
            return
        }

        Lytics.shared.identify(
            identifiers: DemoIdentity(email: email))

        onComplete()
    }

    func forgotPassword() {
        print("\(#function)")
    }
}
