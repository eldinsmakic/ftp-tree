//
//  Program.swift
//  ftp-tree
//
//  Created by eldin smakic on 31/01/2021.
//

protocol Program {
    func launch(host: String, username: String?, password: String?) -> Int
}


final class ProgramTree: Program {
    func launch(host: String, username: String?, password: String?) -> Int {
        let client = Client(host: host, port: 21)
        client.start()
        client.connection.nwConnection.lauchMethod(command: .Connect)
        client.connection.nwConnection.lauchMethod(command: .User("anonymous"))
        client.connection.nwConnection.lauchMethod(command: .Pass("anonymous"))

        client.connection.listTree()

        return 0
    }
}
