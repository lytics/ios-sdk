//
//  LoginViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

final class LoginViewModel:  ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
    }

    func login() {
        print("\(#function)")
    }

    func forgotPassword() {
        print("\(#function)")
    }

    func register() {
        print("\(#function)")
    }
}
