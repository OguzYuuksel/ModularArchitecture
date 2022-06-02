import Foundation

// MARK: Step 1 - Enter arguments
let projectName: String = "LinkNow"
let packageName: String? = "OnlineCourse"
let developer: String = "Oguz\\ Yuksel"
let contact: String = "oguz.yuksel@huawei.com"
let projectPath: String? = "~/Desktop/"
let bundleIDPrefix: String? = "com.huawei"
let packagePath: String? = "~/Desktop/LinkNow/Sources/Packages" // <projectPath>/Sources/Packages
let packageType: String? = "screen"

// MARK: Step 2 - Build Executable
if !FileManager.default.fileExists(atPath: buildFile.path) {
    let buildMAT = Commands.run("cd \(scriptDir!.path); swift build")
    guard buildMAT.statusCode == 0 else {
        echoFailure(buildMAT.output)
        exit(0)
    }
}

// MARK: Step 3 - Remove Executable
try? FileManager.default.removeItem(at: executableFile)

// MARK: Step 4 - Copy Executable
try? FileManager.default.copyItem(at: buildFile, to: executableFile)


// MARK: Step 5 - Run ModularArchitecture CLI
echoInfo("\n\n")
// create-project
if let projectPath = projectPath,
   let bundleIDPrefix = bundleIDPrefix {
    echoInfo("Creating Project...")
    let createProject = Commands.run("\(executableFile.path) create-project -n \(projectName) -b \(bundleIDPrefix) -d \(developer) -c \(contact) -p \(projectPath)")
    guard createProject.statusCode == 0 else {
        echoFailure(createProject.output)
        exit(0)
    }
    echoSuccess(createProject.output)
}

// create-package
if let packagePath = packagePath,
   let packageName = packageName,
   let packageType = packageType {
    echoInfo("Creating Package...")
    let createPackage = Commands.run("\(executableFile.path) create-package -n \(projectName) -package \(packageName) -d \(developer) -c \(contact) -t \(packageType) -p \(packagePath)")
    guard createPackage.statusCode == 0 else {
        echoFailure(createPackage.output)
        exit(0)
    }
    echoSuccess(createPackage.output)
}

// MARK: Step 6 - Remove Executable
try? FileManager.default.removeItem(at: executableFile)

echoInfo("\n")

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

var scriptDir: URL? {
    let cwd = FileManager.default.currentDirectoryPath
    let script = CommandLine.arguments[0]
    
    if script.hasPrefix("/") {
        return URL(fileURLWithPath: (script as NSString).deletingLastPathComponent)
    } else {
        let urlCwd = URL(fileURLWithPath: cwd)
        if let path = URL(string: script, relativeTo: urlCwd)?.path {
            return URL(fileURLWithPath: (path as NSString).deletingLastPathComponent)
        }
        return nil
    }
}

var buildFile: URL { scriptDir!.appendingPathComponent(".build").appendingPathComponent("debug").appendingPathComponent("ModularArchitecture", isDirectory: false) }
var executableFile: URL { scriptDir!.appendingPathComponent("ModularArchitecture", isDirectory: false) }

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
