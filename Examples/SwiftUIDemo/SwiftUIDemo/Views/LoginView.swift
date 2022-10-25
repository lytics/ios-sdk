//
//  LoginView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    enum FocusField: Hashable {
        case email
        case password
    }

    enum Route: Hashable {
        case register
    }

    @FocusState var focusedField: FocusField?
    @StateObject var viewModel: LoginViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome!")
                    .bold()

                VStack(spacing: 16) {
                    TextField(
                        "Email Address",
                        text: $viewModel.email)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }

                    SecureField(
                        "Password",
                        text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.password)

                }
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(
                    action: {
                        viewModel.forgotPassword()
                    },
                    label: {
                        Text("Forgot password?")
                    })

                Button(
                    action: {
                        focusedField = .none
                        viewModel.login()
                    },
                    label: {
                        Text("Login")
                    })
                .buttonStyle(.primary())
                .disabled(!viewModel.loginIsEnabled)

                HStack {
                    Spacer()

                    Text("Not a member?")

                    NavigationLink(value: Route.register) {
                        Text("Register now.")
                    }

                    Spacer()
                }
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .register:
                    RegisterView(viewModel: .init())
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
    }
}
