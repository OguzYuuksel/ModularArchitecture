// Project: ModularArchitecture
// File: ArgumentParserError.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

protocol ArgumentParserError: Error {
    
    // MARK: Properties
    var validationError: ValidationError { get }
}
