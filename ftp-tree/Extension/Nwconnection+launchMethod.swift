//
//  Nwconnection+launchMethod.swift
//  ftp-tree
//
//  Created by eldin smakic on 02/02/2021.
//

import Network

extension NWConnection {

    enum CommandType {
        case Connect
        case User(String)
        case Pass(String)
        case Passive
        case List
        case Cd(String)
    }

    func lauchMethod(command: CommandType) -> String? {
        do {
            switch command {
            case .Connect:
                let cmd  = Connection(nwConnection: self)
                return try cmd.launch()
            case .User(let user):
                let cmd = User(nwConnection: self, username: user)
                return try cmd.launch()
            case .Pass(let password):
                let cmd = Pass(nwConnection: self, password: password)
                return try cmd.launch()
            case .Passive:
                let cmd = Passive(nwConnection: self)
                return try cmd.launch()
            case .List:
                return try List(nwConnection: self).launch()
            case .Cd(let directory):
                return try CD(nwConnection: self, directory: directory).launch()
            }
        } catch let error {
            print(error)
        }
        return nil
    }
}
