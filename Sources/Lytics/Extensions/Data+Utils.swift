//
//  Data+Utils.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

import Foundation

extension Data {

    /// Adds the elements of UTF-8-encoded JSON array data.
    ///
    /// This method will throw an error if either `Data` value does not begin and end with
    /// the `[` and `]` control characters, respectively. It makes no guarantee as to the
    /// contents of the data.
    ///
    /// - Parameter newArrayData: The data to add.
    mutating func append(jsonArray newArrayData: inout Data) throws {
        guard first == .leftSquareBracket,
              last == .rightSquareBracket,
              newArrayData.first == .leftSquareBracket,
              newArrayData.last == .rightSquareBracket else {
            throw LyticsError(reason: "Invalid data format")
        }

        // Handle empty array data
        if count == 2 {
            self = newArrayData
            return
        } else if newArrayData.count == 2 {
            return
        }

        removeLast()
        newArrayData[0] = .comma
        append(newArrayData)
    }
}
