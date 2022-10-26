//
//  Color+Assets.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/26/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI
import UIKit

public extension Color {
    static let cardBackground = Color(.cardBackground)
}

public extension UIColor {
    static let cardBackground = UIColor.color(named: "cardBackground")

    private static func color(named: String) -> UIColor {
        UIColor(
            named: named,
            in: .main,
            compatibleWith: nil)!
    }
}
