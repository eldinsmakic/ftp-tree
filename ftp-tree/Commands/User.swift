//
//  User.swift
//  ftp-tree
//
//  Created by eldin smakic on 18/01/2021.
//

import Foundation
import Network

class User: Command {
    let username: String
    init(nwConnection: NWConnection, username: String) {
        self.username = username

        super.init(nwConnection: nwConnection)
        self.validResponse = 331
        self.commandName = "USER"

    }

    override func launch() throws -> String? {
        let request = "\(self.commandName) \(self.username)"
        var data = request.data(using: .utf8)!
        data.append(contentsOf: [13,10])
        self.send(data: data)
        self.setupReceive()
        return try super.launch()
    }
}
