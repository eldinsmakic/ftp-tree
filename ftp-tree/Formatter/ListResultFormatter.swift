//
//  ListResultFormatter.swift
//  ftp-tree
//
//  Created by eldin smakic on 20/01/2021.
//

import Foundation

public class ListResultFormatter {

    public init() {}

    public func trimMessage(message: String) -> String {
        let range = NSRange(location: 0, length: message.count)
        let regex = try! NSRegularExpression(pattern: "^.*\\r\\n")

        let messageTrimmed = regex.firstMatch(in: message, options: [], range: range)

        let subRange = Range(messageTrimmed!.range, in: message)

        var result = message[subRange!]

        result.removeLast()

        return String(result)
    }
}
