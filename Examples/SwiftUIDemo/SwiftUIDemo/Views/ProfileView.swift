//
//  ProfileView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 24)

                Text("The following is an output of the current user’s stored data in JSON format:")

                Text(viewModel.userJSON)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.all, 8)
            }
            .padding(16)
        }
        .onAppear {
            viewModel.getUser()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static let json = """
        {
          "identifiers": {
            "email": "mark@lytics.com",
            "uuid": "23523-235lk235-2352352",
            "mc_euid": "5c16949974",
            "sendgrid_id": "ZHJld0BseXRpY3MuY29t"
          },
          "attributes": {
            "first_name": "Mark",
            "last_name": "Hayden"
          }
        }
        """

    static var previews: some View {
        ProfileView(viewModel: .init(
            userJSON: json))
    }
}
