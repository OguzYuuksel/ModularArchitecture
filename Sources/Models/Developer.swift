// Project: ModularArchitecture
// File: Developer.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

struct Developer: CustomStringConvertible {
    
    // MARK: Properties
    let description: String
    
    // MARK: Initializations
    init(_ developer: String) throws {
        guard NSPredicate(format: "SELF MATCHES %@", Self.validationPattern).evaluate(with: developer) else {
            throw Error.invalid.validationError
        }
        description = developer
    }
    
    // MARK: Static Properties
    static let shortArgument: Character = "d"
    static let longArgument: String = "developer"
    private static let minCharacterCount: String = "1"
    private static let maxCharacterCount: String = "49"
    private static let validationPattern: String = "(?!\\s)(.){\(minCharacterCount),\(maxCharacterCount)}"
    
    // MARK: Modules
    enum Error: ArgumentParserError {
        
        // MARK: Cases
        case invalid
        
        // MARK: Properties
        var validationError: ValidationError {
            switch self {
            case .invalid:
                return .init(recoverySuggestion: "Please don't use space as first character and do not exceed \(maxCharacterCount) characters.")
            }
        }
    }
}
