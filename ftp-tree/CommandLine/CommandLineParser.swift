//
//  CommandLine.swift
//  ftp-tree
//
//  Created by eldin smakic on 31/01/2021.
//

import Foundation

/**
 Get Input from Command Line and parse it for the program
 */
final class CommandLineParser {
    let arguments: [String]
    let program: Program

    var host: String?
    var username: String?
    var password: String?
    var deepth: String?

    init(arguments: [String], program: Program) {
        self.arguments = arguments
        self.program = program
        self.parse()
    }

    public func lauchCommandLine() {
        guard let host = host else { return }
        self.program.launch(host: host, username: self.username, password: self.password, deepth: self.deepth)
    }

    private func parse() {
        if arguments.count < 2 {
            print("Command invalid")
            self.program.launch(host: "ftp.ubuntu.com", username: "anonymous", password: "anonymous", deepth: "1")
        } else {
            for indice in 1..<arguments.count {
                if arguments[indice] == "-h" {
                    host = arguments[indice+1]
                } else if arguments[indice] == "-u" {
                    username = arguments[indice+1]
                } else if arguments[indice] == "-p" {
                    password = arguments[indice+1]
                } else if arguments[indice] == "-d" {
                    deepth = arguments[indice+1]
                }
            }
            lauchCommandLine()
        }
    }
}
