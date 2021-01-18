//
//  Connection.swift
//  ftp-tree
//
//  Created by eldin smakic on 18/01/2021.
//

import Foundation
import Network

class Connection: Command {
    override init(nwConnection: NWConnection) {
        super.init(nwConnection: nwConnection)
        self.validResponse = 220
    }

    override func launch() throws -> String? {
        self.start()
        self.setupReceive()
        return try super.launch()
    }
}
