// Project: ModularArchitecture
// File: PackageName.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

struct PackageName: CustomStringConvertible {
    
    // MARK: Properties
    let description: String
    
    // MARK: Initializations
    init(_ name: String) throws {
        guard NSPredicate(format: "SELF MATCHES %@", Self.validationPattern).evaluate(with: name) else {
            throw Error.invalid.validationError
        }
        description = name
    }
    
    // MARK: Static Properties
    static let longArgument: String = "package"
    private static let minCharacterCount: String = "3"
    private static let maxCharacterCount: String = "30"
    private static let validationPattern: String = "[a-zA-Z0-9-.]{\(minCharacterCount),\(maxCharacterCount)}"
    
    // MARK: Modules
    enum Error: ArgumentParserError {
        
        // MARK: Cases
        case invalid
        
        // MARK: Properties
        var validationError: ValidationError {
            switch self {
            case .invalid:
                return .init(recoverySuggestion: "Please use English characters, numbers, \"-\", \".\" for the name of Swift Package and don't exceed maximum character count(\(maxCharacterCount))")
            }
        }
    }
}
