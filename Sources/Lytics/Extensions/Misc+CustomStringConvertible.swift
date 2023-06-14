//
//  Misc+CustomStringConvertible.swift
//
//  Created by Mathew Gacy on 12/3/22.
//

import UIKit

// MARK: - UIDeviceOrientation + CustomStringConvertible
extension UIDeviceOrientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .portrait: return "portrait"
        case .portraitUpsideDown: return "portraitUpsideDown"
        case .landscapeLeft: return "landscapeLeft"
        case .landscapeRight: return "landscapeRight"
        case .faceUp: return "faceUp"
        case .faceDown: return "faceDown"
        default: return "unknown"
        }
    }
}

// MARK: - UIUserInterfaceIdiom + CustomStringConvertible
extension UIUserInterfaceIdiom: CustomStringConvertible {
    public var description: String {
        switch self {
        case .carPlay: return "carPlay"
        case .mac: return "mac"
        case .pad: return "pad"
        case .phone: return "phone"
        #if swift(>=5.9)
        case .reality: return "reality"
        #endif
        case .tv: return "tv"
        case .unspecified: return "unspecified"
        @unknown default: return "unknown"
        }
    }
}
