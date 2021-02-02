import Foundation

let programFTP = ProgramTree()
let cmdParser = CommandLineParser(arguments: CommandLine.arguments, program: programFTP)

cmdParser.lauchCommandLine()
dispatchMain()
