//
//  Bundle+Utils.swift
//
//  Created by Mathew Gacy on 10/19/22.
//

import Foundation

extension Bundle {
    /// The user-visible name for the bundle.
    var appName: String? {
        infoDictionary?["CFBundleDisplayName"] as? String ?? infoDictionary?["CFBundleName"] as? String
    }

    /// The release or version number of the bundle.
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    /// The version of the build that identifies an iteration of the bundle.
    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
