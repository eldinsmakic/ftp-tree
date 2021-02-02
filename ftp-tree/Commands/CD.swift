//
//  CD.swift
//  ftp-tree
//
//  Created by eldin smakic on 20/01/2021.
//

import Foundation
import Network

/**
 CD FTP command
 */
class CD: Command {
    var directory: String

     init(nwConnection: NWConnection, directory: String) {
        self.directory = directory

        super.init(nwConnection: nwConnection)
        self.validResponse = 250
        self.commandName = "CWD"
    }

    override func launch() throws -> String? {
        let request = "\(self.commandName) \(self.directory)"
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

