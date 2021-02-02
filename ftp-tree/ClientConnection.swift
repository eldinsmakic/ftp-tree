//
//  ClientConnection.swift
//  ftp-tree
//
//  Created by eldin smakic on 02/02/2021.
//

import Network
import Foundation

/**
 Manage connection betweent the client and the endpoint
 */
class ClientConnection {
    var host = ""
    let nwConnection: NWConnection
    var dataFlowNwConnection: NWConnection?
    let queue = DispatchQueue(label: "Client connection Q")
    let resultFormatter = ListResultFormatter()
    var spacing = 0
    var deepthMax = 999
    var deepth = -1

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.dataFlowNwConnection = nil
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        nwConnection.stateUpdateHandler = stateDidChange(to:)

        nwConnection.start(queue: queue)
    }

    public func listTree() {
        deepth += 1
        if deepth >= deepthMax {
            self.spacing -= 4
            deepth -= 1
            _ = self.nwConnection.lauchMethod(command: .Cd(".."))
            return
        }

        let response = nwConnection.lauchMethod(command: .Passive)

        let newConnection = response!.convertToConnection(host: host)

        self.dataFlowNwConnection = newConnection
        self.dataFlowNwConnection?.start (queue: queue)
        var message: String? = nil

        dataFlowNwConnection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [self] (data, _, isComplete, error) in
            if let error = error {
                self.connectionDidFail(error: error)
            } else {
                message = String(data: data!, encoding: .utf8)
            }
        }

        _ = nwConnection.lauchMethod(command: .List)

        while(message == nil) {
        }

        let contentCWD = self.resultFormatter.mapMessageToTree(message: message!)

        contentCWD.forEach { file in
            print("\(String(repeating: " ", count: self.spacing))|__ \(file[1])")

            if file[0] == "d" {
                self.spacing += 4
                _ = self.nwConnection.lauchMethod(command: .Cd(file[1]))
                self.dataFlowNwConnection?.cancel()
                listTree()
            }
        }
        self.spacing -= 4
        self.deepth -= 1
        _ = self.nwConnection.lauchMethod(command: .Cd(".."))
    }


    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            break
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
        }))
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

