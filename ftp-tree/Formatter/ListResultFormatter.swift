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
        var lastIndex = 0
        let arrayMessage = Array(message)

        for index in 0..<arrayMessage.count {
            if arrayMessage[index] == "\r\n" {
                lastIndex = index
                break
            }
        }

        let result = arrayMessage[0..<lastIndex]

        return String(result)
    }
}
