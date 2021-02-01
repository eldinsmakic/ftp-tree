//
//  CommandLine.swift
//  ftp-tree
//
//  Created by eldin smakic on 31/01/2021.
//

import Foundation

final class CommandLineParser {
    let arguments: [String]
    let program: Program

    var host: String?
    var username: String?
    var password: String?

    init(arguments: [String], program: Program) {
        self.arguments = arguments
        self.program = program
        self.parse()
    }

    public func lauchCommandLine() {
        self.program.launch(host: self.host!, username: self.username, password: self.password)
    }

    private func parse() {
        if arguments.count < 2 {
            print("Command invalid")
        } else {
            for indice in 1..<arguments.count {
                if arguments[indice] == "-h" {
                    host = arguments[indice+1]
                } else if arguments[indice] == "-u" {
                    username = arguments[indice+1]
                } else if arguments[indice] == "-p" {
                    password = arguments[indice+1]
                }
            }
            lauchCommandLine()
        }
    }
}
