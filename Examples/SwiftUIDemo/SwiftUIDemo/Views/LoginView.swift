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

    @FocusState var focusedField: FocusField?
    @StateObject var viewModel: LoginViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Welcome!")
                .bold()

            VStack(spacing: 16) {
                TextField(
                    "Email Address",
                    text: $viewModel.email)

                SecureField(
                    "Password",
                    text: $viewModel.password)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(
                action: {

                },
                label: {
                    Text("Forgot password?")
                })

            Button(
                action: {
                    viewModel.login()
                },
                label: {
                    Text("Login")
                })
            .buttonStyle(.primary())

            HStack {
                Spacer()

                Text("Not a member?")

                Button(
                    action: {
                        viewModel.register()
                    },
                    label: {
                        Text("Register now.")
                    })

                Spacer()
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
    }
}
