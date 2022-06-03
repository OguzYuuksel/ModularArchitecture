// Project: ModularArchitecture
// File: ModularArchitecture.CreateProject.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import ArgumentParser
import Foundation

extension ModularArchitecture {
    
    struct CreateProject: ParsableCommand {
        
        // MARK: Properties
        static var configuration = CommandConfiguration(abstract: "Create new Modular Architecture Project.")
        private var projectDir: URL {
            destination.url.appendingPathComponent(projectName.description)
        }
        
        // Arguments
        @Option(name: [.customShort(ProjectName.shortArgument), .customLong(ProjectName.longArgument, withSingleDash: true)],
                help: "Name of the project & application.",
                transform: ProjectName.init)
        var projectName: ProjectName
        
        @Option(name: [.customShort(BundleID.shortArgument), .customLong(BundleID.longArgument, withSingleDash: true)],
                help: "Prefix for Bundle ID.",
                transform: BundleID.init)
        var bundleIDPrefix: BundleID
        
        @Option(name: [.customShort(Developer.shortArgument), .customLong(Developer.longArgument, withSingleDash: true)],
                help: "Name and surname or registration number of the developer.",
                transform: Developer.init)
        var developer: Developer
        
        @Option(name: [.customShort(Contact.shortArgument), .customLong(Contact.longArgument, withSingleDash: true)],
                help: "Email address or contact number of the developer.",
                transform: Contact.init)
        var contact: Contact
        
        @Option(name: [.customShort(Path.shortArgument), .customLong(Path.longArgument, withSingleDash: true)],
                help: "The path where the project will be created.",
                transform: Path.init)
        var destination: Path
        
        // MARK: Functions
        func validate() throws {
            guard (try? FileManager.default.contentsOfDirectory(at: projectDir, includingPropertiesForKeys: nil)) == nil else {
                throw ValidationError(recoverySuggestion: "Please clean \"\(projectDir.path)\"")
            }
            guard (try? FileManager.default.contentsOfDirectory(at: FileDestination.tcaProjectTeplateDir, includingPropertiesForKeys: nil)) != nil else {
                throw ValidationError(recoverySuggestion: "Empty template path \"\(FileDestination.tcaProjectTeplateDir.path)\"")
            }
            try? FileManager.default.createDirectory(atPath: projectDir.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        }
        
        mutating func run() throws {
            copyTemplateToProjectDir()
            applyVariablesToTemplate()
        }
        
        // Actions
        private func copyTemplateToProjectDir() {
            do {
                try FileManager.default.copyItem(at: FileDestination.tcaProjectTeplateDir, to: projectDir)
            } catch let error {
                terminateWithFailure(reason: error.localizedDescription)
            }
        }
        
        private func applyVariablesToTemplate() {
            let fileEnumator: FileManager.DirectoryEnumerator = {
                let resourceKeys = Set<URLResourceKey>([.isRegularFileKey])
                return FileManager.default.enumerator(at: projectDir, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
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
                                                                      StringSet.template_YYYY: StringSet.date_YYYY,
                                                                      StringSet.template_DDMMYYYY: StringSet.date_DDMMYYYY,
                                                                      StringSet.template_DeveloperNameSurname: developer.description,
                                                                      StringSet.template_DeveloperMail: contact.description,
                                                                      StringSet.template_BundlDPrefix: bundleIDPrefix.description,][$0] })
                    
                    try FileManager.default.removeItem(at: fileURL)

                    try file.write(to: fileURL.deletingPathExtension(), atomically: true, encoding: .utf8)

                } catch let error {
                    terminateWithFailure(reason: error.localizedDescription)
                }
            }
        }
        
        private func terminateWithFailure(reason: String) -> Never {
            echoFailure(reason)
            try? FileManager.default.removeItem(at: projectDir)
            return ModularArchitecture.CreateProject.exit()
        }
        
    }
}
