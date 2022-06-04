import Foundation

// MARK: Step 1 - Enter arguments
let rebuildTool: Bool = // false
let projectName: String = // "<projectName>"^
let developer: String = // "<developerNameSurname>"^
let contact: String = // "<developerContactInfo>"^

// Project
let projectPath: String? = nil // "~/<projectParentDir>"^
let bundleIDPrefix: String? = nil // "com.<projectname>"^

// Package
let packageName: String? = nil // "Settings"^
let packagePath: String? = nil // "~/<projectDir>/Sources/Packages"^
let packageType: String? = nil // "screen"^









// MARK: Step 2 - Remove ModularArchitecture tool from project path.
echoInfo("Removing ModularArchitecture from project path...")
try? FileManager.default.removeItem(at: Destination.projectDirTool.url)
echoSuccess("Completed ✓")

// MARK: Step 3 - Build ModularArchitecture tool.
if !FileManager.default.fileExists(atPath: Destination.buildDirTool.path) || rebuildTool {
    echoInfo("Removing .build directory...")
    try? FileManager.default.removeItem(at: Destination.buildDir.url)
    echoSuccess("Completed ✓")
    
    echoInfo("Building ModularArchitecture tool...")
    let buildTool = Commands.run("cd \(Destination.project.commandsPath); swift build")
    guard buildTool.statusCode == 0 else {
        terminateWithFailure(reason: buildTool.output)
    }
    echoSuccess("Completed ✓")
}

// MARK: Step 4 - Copy ModularArchitecture tool to project path.
echoInfo("Copying ModularArchitecture from build directory to main directory...")
do {
    try FileManager.default.copyItem(at: Destination.buildDirTool.url, to: Destination.projectDirTool.url)
} catch let error {
    terminateWithFailure(reason: error.localizedDescription)
}
echoSuccess("Completed ✓")

// MARK: Step 5 - Running ModularArchitecture tool.
echoInfo("Running ModularArchitecture tool...")

// Creating Project
if let projectPath = projectPath,
   let bundleIDPrefix = bundleIDPrefix {
    echoInfo("Creating Project...")
    let createProject = Commands.run("\(Destination.projectDirTool.commandsPath) create-project -n \(projectName) -b \(bundleIDPrefix) -d \(developer) -c \(contact) -p \(projectPath)")
    guard createProject.statusCode == 0 else {
        terminateWithFailure(reason: createProject.output)
    }
    echoSuccess("Completed ✓")
}

// Creating Package
if let packagePath = packagePath,
   let packageName = packageName,
   let packageType = packageType {
    echoInfo("Creating Package...")
    let createPackage = Commands.run("\(Destination.projectDirTool.commandsPath) create-package -n \(projectName) -package \(packageName) -d \(developer) -c \(contact) -t \(packageType) -p \(packagePath)")
    guard createPackage.statusCode == 0 else {
        terminateWithFailure(reason: createPackage.output)
    }
    echoSuccess("Completed ✓")
}
echoSuccess("Completed ✓")

// MARK: Step 6 - Remove ModularArchitecture tool from project path.
echoInfo("Removing ModularArchitecture from project path...")
try? FileManager.default.removeItem(at: Destination.projectDirTool.url)
echoSuccess("Completed ✓")









// MARK: - Script Helpers
// MARK: Destination
enum Destination {
    
    case project
    case projectDirTool
    case buildDir
    case debugDir
    case buildDirTool
    
    private static let scriptDirectory: URL = scriptDir
    
    var url: URL {
        switch self {
        case .project:
            return Destination.scriptDirectory
            
        case .projectDirTool:
            return Destination.project.url
                .appendingPathComponent("ModularArchitecture", isDirectory: false)
         
        case .buildDir:
            return Destination.project.url
                .appendingPathComponent(".build", isDirectory: true)
            
        case .debugDir:
            return Destination.buildDir.url
                .appendingPathComponent("debug", isDirectory: true)
            
        case .buildDirTool:
            return Destination.debugDir.url
                .appendingPathComponent("ModularArchitecture", isDirectory: false)
        }
    }
    var path: String {
        self.url.path
    }
    var commandsPath: String {
        self.path.commandsString
    }
    
}

// MARK: Termatination
func terminateWithFailure(reason: String) -> Never {
    echoFailure(reason)
    let removingURLs: [URL] = [Destination.projectDirTool.url, Destination.buildDir.url]
    let argumentURLs: [URL] = [projectPath, packagePath].compactMap { $0?.url }
    (removingURLs + argumentURLs).forEach { url in
        try? FileManager.default.removeItem(at: url)
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

extension String {
    
    var commandsString: String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }
    
    var url: URL {
        URL(fileURLWithPath: self)
    }
    
}

postfix operator ^
postfix func ^(string: String) -> String {
    return string.commandsString
}
