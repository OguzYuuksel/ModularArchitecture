// Project: ModularArchitecture
// File: BundleID.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

struct BundleID: CustomStringConvertible {
    
    // MARK: Properties
    let description: String
    
    // MARK: Initializations
    init(_ bundleID: String) throws {
        guard NSPredicate(format: "SELF MATCHES %@", Self.validationPattern).evaluate(with: bundleID) else {
            throw Error.invalid.validationError
        }
        description = bundleID
    }
    
    // MARK: Static Properties
    static let shortArgument: Character = "b"
    static let longArgument: String = "bundle"
    private static let minCharacterCount: String = "3"
    private static let maxCharacterCount: String = "20"
    private static let validationPattern: String = "[a-zA-Z0-9-.]{\(minCharacterCount),\(maxCharacterCount)}"
    
    // MARK: Modules
    enum Error: ArgumentParserError {
        
        // MARK: Cases
        case invalid
        
        // MARK: Properties
        var validationError: ValidationError {
            switch self {
            case .invalid:
                return .init(recoverySuggestion: "Please use English characters, numbers, \"-\", \".\" for the Prefix of Bundle ID and don't exceed maximum character count(\(maxCharacterCount))")
            }
        }
    }
}
