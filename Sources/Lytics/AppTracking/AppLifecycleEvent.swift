//
//  AppLifecycleEvent.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

/// Application lifecycle events.
enum AppLifecycleEvent {
    ///  The application became active.
    case didBecomeActive
    /// The application entered the background.
    case didEnterBackground
    /// The application will terminate.
    case willTerminate
}
