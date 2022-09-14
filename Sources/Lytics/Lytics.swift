//
//  Lytics.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import Foundation

public final class Lytics {

    public static let shared: Lytics = {
        let instance = Lytics()
        // setup code
        return instance
    }()

    public private(set) var hasStarted: Bool = false

    public func start(_ configuration: (LyticsConfiguration) -> Void) {
        // ...
    }
}

