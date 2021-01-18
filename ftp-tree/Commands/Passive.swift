//
//  Passive.swift
//  ftp-tree
//
//  Created by eldin smakic on 18/01/2021.
//

import Foundation
import Network

class Passive: Command {
    override init(nwConnection: NWConnection) {
        super.init(nwConnection: nwConnection)
        self.validResponse = 227
        self.commandName = "PASV"
    }

    override func launch() throws -> String? {
        let request = "\(self.commandName)"
        var data = request.data(using: .utf8)!
        data.append(contentsOf: [13,10])
        self.send(data: data)
        self.setupReceive()
        return try super.launch()
    }

    override func returnResultCommand(message: String) {
        result = message
    }
}
