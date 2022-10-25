//
//  ProfileViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

final class ProfileViewModel:  ObservableObject {
    @Published var userJSON: String

    init(userJSON: String = "") {
        self.userJSON = userJSON
    }

    func getUser() async {
        userJSON = "{}"
    }
}
