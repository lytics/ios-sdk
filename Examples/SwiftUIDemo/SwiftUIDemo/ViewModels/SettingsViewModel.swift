//
//  SettingsViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import Lytics

final class SettingsViewModel: ObservableObject {

    func reset() {
        Lytics.shared.reset()
    }
}
