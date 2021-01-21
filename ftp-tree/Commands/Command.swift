//
//  Command.swift
//  ftp-tree
//
//  Created by eldin smakic on 18/01/2021.
//

import Foundation
import Network

class Command {

    var commandName: String = ""
    var validResponse: Int = -1
    var nwConnection: NWConnection
    var result: String?
    let queue = DispatchQueue(label: "Client connection Q")

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func launch() throws -> String? {
        while (result == nil) {
            sleep(1)
        }
        return result
    }

    func returnResultCommand(message: String) {
        result = message
    }

    func verifyCommand(message: String) throws {
        if !message.contains("\(self.validResponse)") {
//            print("error on \(message)")
        } else {
            returnResultCommand(message: message)
        }
    }

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        nwConnection.start(queue: queue)

    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
//                print("connection did send, data: \(data as NSData)")
        }))
    }

    func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                if let data = data, !data.isEmpty {
                    let message = String(data: data, encoding: .utf8)
//                    print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
                    do {
                        try self.verifyCommand(message: message!)
                    } catch let error {
                        print(error)
                    }
                }

            }
        }
    }

    func stop() {
        print("connection will stop")
        stop(error: nil)
    }

    private func connectionDidFail(error: Error) {
        print("connection did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}

