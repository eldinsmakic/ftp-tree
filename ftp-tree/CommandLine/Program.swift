//
//  Program.swift
//  ftp-tree
//
//  Created by eldin smakic on 31/01/2021.
//

protocol Program {
    func launch(host: String, username: String?, password: String?, deepth: String?) -> Int
}


final class ProgramTree: Program {
    func launch(host: String, username: String?, password: String?, deepth: String?) -> Int {
        let client = Client(host: host, port: 21)

        if let deepth = deepth {
            client.connection.deepthMax = Int(deepth)!
        }

        client.start()
        client.connection.nwConnection.lauchMethod(command: .Connect)

        if let username = username,
           let password = password {
            client.connection.nwConnection.lauchMethod(command: .User(username))
            client.connection.nwConnection.lauchMethod(command: .Pass(password))
        }

        client.connection.listTree()
        return 0
    }
}
