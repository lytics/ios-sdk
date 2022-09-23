//
//  OSLog+Utils.swift
//
//  Created by Mathew Gacy on 9/16/22.
//

import Foundation
import os.log

extension OSLog {
    func callAsFunction(_ string: String) {
        os_log("%{public}s", log: self, string)
    }
}
