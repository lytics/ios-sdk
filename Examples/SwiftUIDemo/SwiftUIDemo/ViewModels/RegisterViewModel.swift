//
//  RegisterViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import Lytics

final class RegisterViewModel:  ObservableObject {
    @Published var name: String
    @Published var email: String
    @Published var password: String
    @Published var agreedToTerms: Bool
    @Published var enableIDFA: Bool

    var registerIsEnabled: Bool {
        name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        agreedToTerms
    }

    init(
        name: String = "",
        email: String = "",
        password: String = "",
        agreedToTerms: Bool = false,
        enableIDFA: Bool = false
    ) {
        self.name = name
        self.email = email
        self.password = password
        self.agreedToTerms = agreedToTerms
        self.enableIDFA = enableIDFA
    }

    func register() {
        guard registerIsEnabled else {
            return
        }

        let consent = DemoConsent(
            documents: ["terms_aug_2022", "privacy_may_2022"],
            consented: true)

        let identity = DemoIdentity(
            email: email,
            name: name)

        if enableIDFA {
            Task {
                let didAuthorize = await Lytics.shared.requestTrackingAuthorization()
                if didAuthorize {
                    print("Authorized")
                } else {
                    print("Denied")
                }

                Lytics.shared.identify(identifiers: identity)
                Lytics.shared.consent(consent: consent)
            }
        } else {
            Lytics.shared.identify(identifiers: identity)
            Lytics.shared.consent(consent: consent)
        }
    }
}
