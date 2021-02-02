//
//  String+convertToConnection.swift
//  ftp-tree
//
//  Created by eldin smakic on 02/02/2021.
//

import Foundation
import Network

extension String {
    func convertToConnection(host: String) -> NWConnection {
        let message = self
        let range = NSRange(location: 0, length: message.count)
        let regex = try! NSRegularExpression(pattern: "\\(.*\\)")
        let address = regex.firstMatch(in: message, options: [], range: range)

        var result = message[Range(address!.range, in: message)!]
        result.removeFirst()
        result.removeLast()

        let arrayAddress = result.split(separator: ",")

        let port = Int(arrayAddress[4])! * 256 + Int(arrayAddress[5])!

        let nwConnection = NWConnection(host: .init(host), port: .init(integerLiteral: .init(port)), using: .tcp)
        return nwConnection
    }

}
