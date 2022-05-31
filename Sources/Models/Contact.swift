// Project: ModularArchitecture
// File: Contact.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

struct Contact: CustomStringConvertible {
    
    // MARK: Properties
    let description: String
    
    // MARK: Initializations
    init(_ contact: String) throws {
        guard NSPredicate(format: "SELF MATCHES %@", Self.emailValidationPattern).evaluate(with: contact) ||
              NSPredicate(format: "SELF MATCHES %@", Self.phoneValidationPattern).evaluate(with: contact) else {
            throw Error.invalid.validationError
        }
        description = contact
    }
    
    // MARK: Static Properties
    static let shortArgument: Character = "c"
    static let longArgument: String = "contact"
    private static let emailValidationPattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    private static let phoneValidationPattern: String = "(\\+|\\d{1})(\\d{1}|-|\\s){1,20}"
    
    // MARK: Modules
    enum Error: ArgumentParserError {
        
        // MARK: Cases
        case invalid
        
        // MARK: Properties
        var validationError: ValidationError {
            switch self {
            case .invalid:
                return .init(recoverySuggestion: "Please enter a valid phone number or email.")
            }
        }
    }
}
