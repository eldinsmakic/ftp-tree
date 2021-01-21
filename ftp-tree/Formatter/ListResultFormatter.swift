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

        if lastIndex == 0 {
            lastIndex = arrayMessage.count
        }

        let result = arrayMessage[0..<lastIndex]

        return String(result)
    }

    public func mapMessageToTree(message: String) -> [[String]] {
        let array = message.split(separator: "\r\n")
        var result = [[String]]()

        array.forEach { element in
            let arrayElement = element.split(separator: " ")
            let length = arrayElement.count
            result.append(
                [
                    String(arrayElement[length - 2]),
                    trimMessage(message: String(arrayElement[length - 1]))
                ]
            )
        }

        return result
    }
}
