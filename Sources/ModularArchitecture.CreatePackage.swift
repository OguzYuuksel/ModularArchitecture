// Project: ModularArchitecture
// File: ModularArchitecture.CreatePackage.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import ArgumentParser
import Foundation

extension ModularArchitecture {
    
    struct CreatePackage: ParsableCommand {
        
        // MARK: Properties
        static var configuration = CommandConfiguration(abstract: "Create new Swift Package for the project.")
        private var packageDir: URL {
            destination.url.appendingPathComponent(packageName.description + type.rawValue.uppercasedFirst())
        }
        
        // Arguments
        @Option(name: [.customShort(ProjectName.shortArgument), .customLong(ProjectName.longArgument, withSingleDash: true)],
                help: "Name of the project & application.",
                transform: ProjectName.init)
        var projectName: ProjectName
        
        @Option(name: [.customLong(PackageName.longArgument, withSingleDash: true)],
                help: "Name of the package.",
                transform: PackageName.init)
        var packageName: PackageName
        
        @Option(name: [.customShort(Developer.shortArgument), .customLong(Developer.longArgument, withSingleDash: true)],
                help: "Name and surname or registration number of the developer.",
                transform: Developer.init)
        var developer: Developer
        
        @Option(name: [.customShort(Contact.shortArgument), .customLong(Contact.longArgument, withSingleDash: true)],
                help: "Email address or contact number of the developer.",
                transform: Contact.init)
        var contact: Contact
        
        @Option(name: [.customShort(PackageType.shortArgument), .customLong(PackageType.longArgument, withSingleDash: true)],
                help:"Type of the package.\n<<PackageName>>Screen - s or screen,\n<<PackageName>>Client - c or client\nLeave empty for default.")
        var type: PackageType = .none
        
        @Option(name: [.customShort(Path.shortArgument), .customLong(Path.longArgument, withSingleDash: true)],
                help: "The path where the package will be created.",
                transform: Path.init)
        var destination: Path
        
        // MARK: Functions
        func validate() throws {
            guard (try? FileManager.default.contentsOfDirectory(at: packageDir, includingPropertiesForKeys: nil)) == nil else {
                throw ValidationError(recoverySuggestion: "Please clean \"\(packageDir.path)\"")
            }
            guard (try? FileManager.default.contentsOfDirectory(at: type.templateDir, includingPropertiesForKeys: nil)) != nil else {
                throw ValidationError(recoverySuggestion: "Empty template path \"\(type.templateDir.path)\"")
            }
        }
        
        mutating func run() {
            copyTemplateToPackageDir()
            renameFiles()
            applyVariablesToTemplate()
        }
        
        // Actions
        private func copyTemplateToPackageDir() {
            do {
                try FileManager.default.copyItem(at: type.templateDir, to: packageDir)
            } catch let error {
                terminateWithFailure(reason: error.localizedDescription)
            }
        }
        
        private func renameFiles() {
            var isDirectoryChanged = false
            
            // TODO: Traverse strategy should be Files -> SubFolders -> Folders
            let fileEnumator: FileManager.DirectoryEnumerator = {
                let resourceKeys = Set<URLResourceKey>([.isRegularFileKey, .isDirectoryKey])
                return FileManager.default.enumerator(at: packageDir, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsHiddenFiles])!
            }()
            
            for case let fileURL as URL in fileEnumator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey]),
                      resourceValues.isRegularFile == true || // URL is file.
                      resourceValues.isDirectory == true // URL is directory.
                else {
                    continue
                }
                let fileName = fileURL.lastPathComponent
                
                switch fileName {
                case _ where fileName.hasPrefix(StringSet.template_PackageName):
                    do {
                            let sourceDir = fileURL.deletingLastPathComponent()
                            let newPrefix = packageName.description.uppercasedFirst()
                            let newSuffix = fileURL.lastPathComponent.dropFirst(StringSet.template_PackageName.count)
                            let newURL = sourceDir.appendingPathComponent( newPrefix + newSuffix )
                            try FileManager.default.moveItem(at: fileURL, to: newURL)
                            isDirectoryChanged = true
                    } catch {
                        terminateWithFailure(reason: error.localizedDescription)
                    }
                    
                case _ where fileName.hasPrefix(StringSet.template_packageName):
                        do {
                                let sourceDir = fileURL.deletingLastPathComponent()
                                let newPrefix = packageName.description.lowercasedFirst()
                                let newSuffix = fileURL.lastPathComponent.dropFirst(StringSet.template_packageName.count)
                                let newURL = sourceDir.appendingPathComponent( newPrefix + newSuffix )
                                try FileManager.default.moveItem(at: fileURL, to: newURL)
                                isDirectoryChanged = true
                        } catch {
                            terminateWithFailure(reason: error.localizedDescription)
                        }
                    
                case _ where fileName.hasPrefix(StringSet.template_packagename):
                    do {
                            let sourceDir = fileURL.deletingLastPathComponent()
                            let newPrefix = packageName.description.lowercased()
                            let newSuffix = fileURL.lastPathComponent.dropFirst(StringSet.template_packagename.count)
                            let newURL = sourceDir.appendingPathComponent( newPrefix + newSuffix )
                            try FileManager.default.moveItem(at: fileURL, to: newURL)
                            isDirectoryChanged = true
                    } catch {
                        terminateWithFailure(reason: error.localizedDescription)
                    }
                    
                default:
                    continue
                }
                
            }
            if isDirectoryChanged { renameFiles() }
        }
        
        private func applyVariablesToTemplate() {
            let fileEnumator: FileManager.DirectoryEnumerator = {
                let resourceKeys = Set<URLResourceKey>([.isRegularFileKey])
                return FileManager.default.enumerator(at: packageDir, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
            }()
            
            for case let fileURL as URL in fileEnumator {
                let pathExtension = "MAT"
                
                guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                      resourceValues.isRegularFile == true, // URL has file.
                      fileURL.pathExtension == pathExtension // file has ".MAT" extension.
                else {
                    continue
                }
                
                do {
                    let file = try String(contentsOf: fileURL)
                        .replacingOccurrences(matchingPattern: "<<[^\\s><]+>>", // TODO: Try not to match "<<", ">>" strings instead of "<", ">" characters.
                                              replacementProvider: { [StringSet.template_ProjectName: projectName.description,
                                                                      StringSet.template_projectName: projectName.description.lowercasedFirst(),
                                                                      StringSet.template_projectname: projectName.description.lowercased(),
                                                                      StringSet.template_PackageName: packageName.description,
                                                                      StringSet.template_packageName: packageName.description.lowercasedFirst(),
                                                                      StringSet.template_packagename: packageName.description.lowercased(),
                                                                      StringSet.template_YYYY: StringSet.date_YYYY,
                                                                      StringSet.template_DDMMYYYY: StringSet.date_DDMMYYYY,
                                                                      StringSet.template_DeveloperNameSurname: developer.description,
                                                                      StringSet.template_DeveloperMail: contact.description,][$0] })
                    
                    try FileManager.default.removeItem(at: fileURL)
                    
                    try file.write(to: fileURL.deletingPathExtension(), atomically: true, encoding: .utf8)
                    
                } catch let error {
                    terminateWithFailure(reason: error.localizedDescription)
                }
            }
        }
        
        private func terminateWithFailure(reason: String) -> Never {
            echoFailure(reason)
            try? FileManager.default.removeItem(at: packageDir)
            return ModularArchitecture.CreatePackage.exit()
        }
        
    }
}

