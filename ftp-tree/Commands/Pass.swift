//
//  Pass.swift
//  ftp-tree
//
//  Created by eldin smakic on 18/01/2021.
//

import Foundation
import Network

class Pass: Command {
    let password: String
    init(nwConnection: NWConnection, password: String) {
        self.password = password

        super.init(nwConnection: nwConnection)
        self.validResponse = 230
        self.commandName = "PASS"

    }

    override func launch() throws -> String? {
        let request = "\(self.commandName) \(self.password)"
        var data = request.data(using: .utf8)!
        data.append(contentsOf: [13,10])
        self.send(data: data)
        self.setupReceive()
        return try super.launch()
    }
}

