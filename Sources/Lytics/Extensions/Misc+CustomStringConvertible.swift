//
//  Misc+CustomStringConvertible.swift
//
//  Created by Mathew Gacy on 12/3/22.
//

import UIKit

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

extension UIUserInterfaceIdiom: CustomStringConvertible {
    public var description: String {
        switch self {
        case .carPlay: return "carPlay"
        case .mac: return "mac"
        case .pad: return "pad"
        case .phone: return "phone"
        case .tv: return "tv"
        case .unspecified: return "unspecified"
        @unknown default: return "unknown"
        }
    }
}
