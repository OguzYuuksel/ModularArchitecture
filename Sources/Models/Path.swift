// Project: ModularArchitecture
// File: Path.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

struct Path: CustomStringConvertible {
    
    // MARK: Properties
    let description: String
    var url: URL {
         .init(fileURLWithPath: description)
    }
    
    // MARK: Initializations
    init(_ path: String) throws {
        // TODO: Find regex pattern for below.
        guard !(path.contains("/.") || path.contains(":")) else {
            throw Error.invalidCharacters.validationError
        }
        guard path.hasPrefix(FileManager.default.homeDirectoryForCurrentUser.path) else {
            throw Error.invalidPath.validationError
        }
        
        description = path
    }
    
    // MARK: Static Properties
    static let shortArgument: Character = "p"
    static let longArgument: String = "path"
    
    // MARK: Modules
    enum Error: ArgumentParserError {
        
        // MARK: Cases
        case invalidCharacters
        case invalidPath
        
        // MARK: Properties
        var validationError: ValidationError {
            switch self {
            case .invalidCharacters:
                return .init(recoverySuggestion: "Path components cannot start with \".\" and cannot contain \":\"")
            case .invalidPath:
                return .init(recoverySuggestion: "Path should begin with ~/<destination>")
            }
        }
    }
}
