//
//  Constants.swift
//
//  Created by Mathew Gacy on 10/20/22.
//

import Foundation

enum Constants {
    static let baseDirectory = "com.lytics.ios-sdk"
    static let requestStorageDirectory = "requests"
    static let requestStorageFilename = "requests"

    static let defaultAnonymousIdentityKey = "_uid"
    static let defaultPrimaryIdentityKey = "_uid"

    static let defaultBaseURL = URL(string: "https://api.lytics.io")!
    static let defaultAPIPath = ""
    static let defaultStream: String = "ios_sdk"
    static let idfaKey: String = "idfa"
    static let defaultAppVersion = "0.0"
}
