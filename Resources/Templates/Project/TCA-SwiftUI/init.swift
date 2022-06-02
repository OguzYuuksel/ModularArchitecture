import Foundation

// MARK: Step 1 - Clean .xcodeproj
echoInfo("Removing .xcodeproj if exists.")
try? FileManager.default.removeItem(at: Destination.xcodeproj.url)
echoSuccess("Completed ✓")

// MARK: Step 2 - Install XcodeGen
echoInfo("Checking if XcodeGen is installed - installing XcodeGen in \"/Resources/Tools\".")
var xcodegen: String = {
    let version = "2.29.0"
    lazy var xcodegenToolPath = "\(Destination.xcodegen.commandsPath)/.build/debug/XcodeGen"
    
    switch true {
    case Commands.run("xcodegen --version").output == "Version: \(version)":
        return "xcodegen"
        
    case Commands.run("\(xcodegenToolPath) --version").output == "Version: \(version)":
        return xcodegenToolPath
        
    default:
        try? FileManager.default.removeItem(at: Destination.xcodegen.url)
        
        let clone = Commands.run("git clone https://github.com/yonaskolb/XcodeGen.git \(Destination.xcodegen.commandsPath)")
        guard clone.statusCode == 0 else {
            terminateWithFailure(reason: clone.output)
        }
        
        let checkout = Commands.run("cd \(Destination.xcodegen.commandsPath); git checkout tags/\(version)")
        guard checkout.statusCode == 0 else {
            terminateWithFailure(reason: checkout.output)
        }
        
        let build = Commands.run("cd \(Destination.xcodegen.commandsPath); swift build")
        guard build.statusCode == 0 else {
            terminateWithFailure(reason: build.output)
        }
        
        let versionCheck = Commands.run("\(xcodegenToolPath) --version")
        guard versionCheck.statusCode == 0 else {
            terminateWithFailure(reason: versionCheck.output)
        }
        guard versionCheck.output == "Version: \(version)" else {
            terminateWithFailure(reason: "\(versionCheck.output) but required version \(version)")
        }
        
        return xcodegenToolPath
    }
}()
echoSuccess("Completed ✓")

// MARK: Step 3 - Install swift-format
echoInfo("Checking if swift-format is installed - installing swift-format in \"/Resources/Tools\".")
var swiftformat: String = {
    let version = "0.50500.0"
    lazy var swiftformatToolPath = "\(Destination.swiftformat.commandsPath)/.build/debug/swift-format"
    
    switch true {
    case Commands.run("swift-format --version").output == version:
        return "swift-format"
        
    case Commands.run("\(swiftformatToolPath) --version").output == version:
        return swiftformatToolPath
        
    default:
        try? FileManager.default.removeItem(at: Destination.swiftformat.url)
        
        let clone = Commands.run("git clone https://github.com/apple/swift-format.git \(Destination.swiftformat.commandsPath)")
        guard clone.statusCode == 0 else {
            terminateWithFailure(reason: clone.output)
        }
        
        let checkout = Commands.run("cd \(Destination.swiftformat.commandsPath); git checkout tags/\(version)")
        guard checkout.statusCode == 0 else {
            terminateWithFailure(reason: checkout.output)
        }
        
        let build = Commands.run("cd \(Destination.swiftformat.commandsPath); swift build")
        guard build.statusCode == 0 else {
            terminateWithFailure(reason: build.output)
        }
        
        let versionCheck = Commands.run("\(swiftformatToolPath) --version")
        guard versionCheck.statusCode == 0 else {
            terminateWithFailure(reason: versionCheck.output)
        }
        guard versionCheck.output == version else {
            terminateWithFailure(reason: "\(versionCheck.output) but required version \(version)")
        }
        
        return swiftformatToolPath
    }
}()
echoSuccess("Completed ✓")

// MARK: Step 4 - Run XcodeGen
echoInfo("Generating .xcodeproj via XcodeGen.")
let xcodegenGenerate = Commands.run("\(xcodegen) -s \(Destination.resources.commandsPath)/XcodeGen/Project.yml -p \(Destination.project.commandsPath) -r \(Destination.project.commandsPath)")
guard xcodegenGenerate.statusCode == 0 else {
    terminateWithFailure(reason: xcodegenGenerate.output)
}
echoSuccess("Completed ✓")

// MARK: Step 5 - Clean auto generated .xcschemes
echoInfo("Cleaning auto generated .xcschemes")
try? FileManager.default.removeItem(at: Destination.xcodeprojSchemes.url)
echoSuccess("Completed ✓")

// MARK: Step 6 - Copy .xcschemes
echoInfo("Copying Resources/Schemes into .xcschemes")
try? FileManager.default.copyItem(at: Destination.schemes.url, to: Destination.xcodeprojSchemes.url)
echoSuccess("Completed ✓")

// MARK: Step 7 - Run swift-format
// where to add? post commit, pre commit, pre built, post build, inside modules?











// MARK: - Script Helpers
// MARK: Destination
enum Destination {
    
    case project
    case resources
    case tools
    case xcodegen
    case schemes
    case swiftformat
    case xcodeproj
    case xcodeprojSchemes
    
    private static let scriptDirectory: URL = scriptDir
    
    var url: URL {
        switch self {
        case .project:
            return Destination.scriptDirectory
            
        case .resources:
            return Destination.project.url.appendingPathComponent("Resources", isDirectory: true)
            
        case .tools:
            return Destination.resources.url.appendingPathComponent("Tools", isDirectory: true)
            
        case .xcodegen:
            return Destination.tools.url.appendingPathComponent("XcodeGen", isDirectory: true)
            
        case .swiftformat:
            return Destination.tools.url.appendingPathComponent("swift-format", isDirectory: true)
            
        case .schemes:
            return Destination.resources.url
                .appendingPathComponent("Schemes", isDirectory: true)
            
        case .xcodeproj:
            let fileName = try? FileManager.default.contentsOfDirectory(atPath: Destination.project.path).first { $0.hasSuffix(".xcodeproj") }
            return Destination.project.url.appendingPathComponent(fileName ?? ".xcodeproj")
        
        case .xcodeprojSchemes:
            return Destination.xcodeproj.url
                .appendingPathComponent("xcshareddata", isDirectory: true)
                .appendingPathComponent("xcschemes", isDirectory: true)
        }
    }
    var path: String {
        self.url.path
    }
    var commandsPath: String {
        self.path.replacingOccurrences(of: " ", with: "\\ ")
    }
    
}

// MARK: Termatination
func terminateWithFailure(reason: String) -> Never {
    echoFailure(reason)
    let removingPaths: [Destination] = [.xcodeproj, .xcodegen, .swiftformat]
    removingPaths.forEach { path in
        try? FileManager.default.removeItem(at: path.url)
    }
    return exit(EXIT_FAILURE)
}











// MARK: - Swift Helpers
// MARK: Shell Support
enum Commands {
    
    static func run(_ command: String,
                    environment: [String: String]? = nil,
                    executableURL: String = "/bin/bash",
                    dashc: String = "-c") -> Result {
        // create process
        func create(_ executableURL: String,
                    dashc: String,
                    environment: [String: String]?) -> Process {
            let process = Process()
            if #available(macOS 10.13, *) {
                process.executableURL = URL(fileURLWithPath: executableURL)
            } else {
                process.launchPath = "/bin/bash"
            }
            if let environment = environment {
                process.environment = environment
            }
            process.arguments = [dashc, command]
            return process
        }
        
        // run process
        func run(_ process: Process) throws {
            if #available(macOS 10.13, *) {
                try process.run()
            } else {
                process.launch()
            }
            process.waitUntilExit()
        }
        
        // read data
        func fileHandleData(fileHandle: FileHandle) throws -> String? {
            var outputData: Data?
            if #available(macOS 10.15.4, *) {
                outputData = try fileHandle.readToEnd()
            } else {
                outputData = fileHandle.readDataToEndOfFile()
            }
            if let outputData = outputData {
                return String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return nil
        }
        
        let process = create(executableURL, dashc: dashc, environment: environment)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        do {
            try run(process)
            
            let outputActual = try fileHandleData(fileHandle: outputPipe.fileHandleForReading) ?? ""
            let errorActual = try fileHandleData(fileHandle: errorPipe.fileHandleForReading) ?? ""
            
            if process.terminationStatus == EXIT_SUCCESS {
                return Result(statusCode: process.terminationStatus, output: outputActual)
            }
            return Result(statusCode: process.terminationStatus, output: errorActual)
        } catch let error {
            return Result(statusCode: process.terminationStatus, output: error.localizedDescription)
        }
        
    }
    
    struct Result {
        public let statusCode: Int32
        public let output: String
    }
    
}

func readSTDIN () -> String? {
    var input: String?
    
    while let line = readLine() {
        if input == nil {
            input = line
        } else {
            input! += "\n" + line
        }
    }
    
    return input
}

func readLine(exitCode: String) -> String? {
    let input = readLine()
    guard input != exitCode else {
        exit(0)
    }
    return input
}

var readLineWithQuit: String? {
    readLine(exitCode: "quit")
}

var scriptDir: URL {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    return URL(fileURLWithPath: CommandLine.arguments[0], relativeTo: currentDirectoryURL).deletingLastPathComponent()
}

// MARK: Echo
var echoClear: Void {
    print("\u{1B}[2J")
    print("\u{1B}[\(1);\(0)H", terminator: "")
}

func echoRequest(_ input: String) {
    print("\(input, color: .cyan)")
}

func echoFailure(_ input: String) {
    print("\(input, color: .red)")
}

func echoSuccess(_ input: String) {
    print("\(input, color: .green)")
}

func echoInfo(_ input: String) {
    print("\(input, color: .magenta)")
}

enum ASCIIColor: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

extension DefaultStringInterpolation {
    
    mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T, color: ASCIIColor) {
        appendInterpolation("\(color.rawValue)\(value)\(ASCIIColor.default.rawValue)")
    }
    
}
