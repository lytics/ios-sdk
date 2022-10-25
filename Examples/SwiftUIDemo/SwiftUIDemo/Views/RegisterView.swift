//
//  RegisterView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct RegisterView: View {
    enum FocusField: Hashable {
        case name
        case email
        case password
    }

    @FocusState var focusedField: FocusField?
    @StateObject var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sign Up")
                    .bold()

                Text("Create an account to get started ")
            }

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")

                    TextField("Name", text: $viewModel.name)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")

                    TextField("Email Address", text: $viewModel.email)
                }

                SecureField("Create a password", text: $viewModel.password)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            VStack(alignment: .leading) {
                Toggle(isOn: $viewModel.agreedToTerms) {
                    Text("I've read and agree with the **Terms and Conditions** and the **Privacy Policy**.")
                        .multilineTextAlignment(.leading)
                }
                .toggleStyle(.checklist())

                Toggle(isOn: $viewModel.enableIDFA) {
                    Text("Improve my experience with better personalization (IDFA Demo).")
                        .multilineTextAlignment(.leading)
                }
                .toggleStyle(.checklist())
            }
            .multilineTextAlignment(.center)

            Button(
                action: {
                    viewModel.register()
                },
                label: {
                    Text("Complete")
                })
            .buttonStyle(.primary())
            .disabled(!viewModel.registerIsEnabled)
        }
        .padding()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: .init())
    }
}
