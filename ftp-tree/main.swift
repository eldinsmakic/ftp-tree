import Foundation
import Network

@available(OSX 10.14, *)

protocol ResultCommand {
    associatedtype R

    var result: R { get set }
}

class NoneResult: ResultCommand {
    var result: String
    init() {
        self.result = "hher"
    }
}

class StringResult: ResultCommand {
    var result: String
    init(result: String) {
        self.result = result
    }
}

@available(OSX 10.14, *)
class ConnectionResult: ResultCommand {
    var result: NWConnection

    init(nwConnection: NWConnection) {
        self.result = nwConnection
    }
}
@available(OSX 10.14, *)
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
            print("error")
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
                print("connection did send, data: \(data as NSData)")
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
                    print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
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

@available(OSX 10.14, *)
extension NWConnection {

    enum CommandType {
        case Connect
        case User
        case Pass
        case Passive
        case List
    }

    func lauchMethod(command: CommandType) -> String? {
        do {
            switch command {
            case .Connect:
                let cmd  = Connection(nwConnection: self)
                return try cmd.launch()
            case .User:
                let cmd = User(nwConnection: self, username: "demo")
                return try cmd.launch()
            case .Pass:
                let cmd = Pass(nwConnection: self, password: "password")
                return try cmd.launch()
            case .Passive:
                let cmd = Passive(nwConnection: self)
                return try cmd.launch()
            case .List:
                return try List(nwConnection: self).launch()
            }
        } catch let error {
            print(error)
        }
        return nil
    }
}

@available(OSX 10.14, *)
class User: Command {
    let username: String
    init(nwConnection: NWConnection, username: String) {
        self.username = username

        super.init(nwConnection: nwConnection)
        self.validResponse = 331
        self.commandName = "USER"

    }

    override func launch() throws -> String? {
        let request = "\(self.commandName) \(self.username)"
        var data = request.data(using: .utf8)!
        data.append(contentsOf: [13,10])
        self.send(data: data)
        self.setupReceive()
        return try super.launch()
    }
}

@available(OSX 10.14, *)
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


@available(OSX 10.14, *)
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

@available(OSX 10.14, *)
class Passive: Command {
    override init(nwConnection: NWConnection) {
        super.init(nwConnection: nwConnection)
        self.validResponse = 227
        self.commandName = "PASV"
    }

    override func launch() throws -> String? {
        let request = "\(self.commandName)"
        var data = request.data(using: .utf8)!
        data.append(contentsOf: [13,10])
        self.send(data: data)
        self.setupReceive()
        return try super.launch()
    }

    override func returnResultCommand(message: String) {
        result = message
    }
}

@available(OSX 10.14, *)
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
        return try super.launch()
    }

    override func returnResultCommand(message: String) {
        result = message
    }
}

@available(OSX 10.14, *)
class ClientConnection {

    let nwConnection: NWConnection
    var dataFlowNwConnection: NWConnection?
    let queue = DispatchQueue(label: "Client connection Q")

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.dataFlowNwConnection = nil
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)

        nwConnection.start(queue: queue)
        _ = nwConnection.lauchMethod(command: .Connect)
        _ = nwConnection.lauchMethod(command: .User)
        _ = nwConnection.lauchMethod(command: .Pass)
        let response = nwConnection.lauchMethod(command: .Passive)
        let newConnection = convertToConnection(message: response!)
        self.dataFlowNwConnection = newConnection
        self.dataFlowNwConnection?.start(queue: queue)
        setupReceive()
        _ = nwConnection.lauchMethod(command: .List)
    }

    private func mapMessageToTree(message: String) {
        let array = message.split(separator: " ")
        print(array)
        print("\(array[2]) \(array[3])")
        print("\(array[5]) \(array[6])")
    }

    private func convertToConnection(message: String) -> NWConnection {
        let range = NSRange(location: 0, length: message.count)
        let regex = try! NSRegularExpression(pattern: "\\(.*\\)")
        let address = regex.firstMatch(in: message, options: [], range: range)

        var result = message[Range(address!.range, in: message)!]
        result.removeFirst()
        result.removeLast()

        let arrayAddress = result.split(separator: ",")
        let ip = arrayAddress[...3].joined(separator: ".")
        let port = Int(arrayAddress[4])! * 256 + Int(arrayAddress[5])!
        print("hello \(ip) and \(port)")

        let nwConnection = NWConnection(host: .init(ip), port: .init(integerLiteral: .init(port)), using: .tcp)
        return nwConnection
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
                print("connection did send, data: \(data as NSData)")
        }))
    }

    func setupReceive() {
        dataFlowNwConnection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                if let data = data, !data.isEmpty {
                    let message = String(data: data, encoding: .utf8)
                    print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
                    self.mapMessageToTree(message: message!)
                    self.setupReceive()
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


if #available(OSX 10.14, *) {
    let client = Client(host: "test.rebex.net", port: 21)
    client.start()
    dispatchMain()
} else {
    print("hh")
}
