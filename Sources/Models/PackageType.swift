// Project: ModularArchitecture
// File: PackageType.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

enum PackageType: String, ExpressibleByArgument, CaseIterable {
    
    // MARK: Cases
    case screen = "Screen"
    case client = "Client"
    case none = ""
    
    // MARK: Properties
    var templateDir: URL {
        switch self {
        case .screen:
            return FileDestination.screenPackageTeplateDir
            
        case .client:
            return FileDestination.clientPackageTeplateDir
            
        case .none:
            return URL(fileURLWithPath: "")
        }
    }
    
    // MARK: Initializations
    init(argument: String) {
        switch argument {
        case "s", "screen":
            self = .screen
        case "c", "client":
            self = .client
        default:
            self = .none
        }
    }
    
    // MARK: Static Properties
    static let shortArgument: Character = "t"
    static let longArgument: String = "type"
}
