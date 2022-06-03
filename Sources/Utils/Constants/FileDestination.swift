// Project: ModularArchitecture
// File: FileDestination.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation

enum FileDestination {
    
    // MARK: Static Properties
    static var currentDir: URL! {
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
    static let resourcesDir: URL = currentDir.appendingPathComponent("Resources")
    static let templatesDir: URL = resourcesDir.appendingPathComponent("Templates")
    static let packageTeplatesDir: URL = templatesDir.appendingPathComponent("Package")
    static let projectTeplatesDir: URL = templatesDir.appendingPathComponent("Project")
    static let clientPackageTeplateDir: URL = packageTeplatesDir.appendingPathComponent("<<PackageName>>Client")
    static let screenPackageTeplateDir: URL = packageTeplatesDir.appendingPathComponent("<<PackageName>>Screen")
    static let tcaProjectTeplateDir: URL = projectTeplatesDir.appendingPathComponent("TCA-SwiftUI")
}
