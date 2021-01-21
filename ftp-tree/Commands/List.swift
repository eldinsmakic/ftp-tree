//
//  List.swift
//  ftp-tree
//
//  Created by eldin smakic on 18/01/2021.
//

import Foundation
import Network

class List: Command {

    override init(nwConnection: NWConnection) {
        super.init(nwConnection: nwConnection)
        self.validResponse = 150
        self.commandName = "LIST"
    }

    override func launch() throws -> String? {
        let request = "\(self.commandName)"
        var data = request.data(using: .utf8)!
        data.append(contentsOf: [13,10])
        self.send(data: data)
        self.setupReceive()
        let result = try super.launch()
        self.setupReceive()
        return result
    }

    override func returnResultCommand(message: String) {
        result = message
    }

}
