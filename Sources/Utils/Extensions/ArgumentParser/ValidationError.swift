// Project: ModularArchitecture
// File: ValidationError.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation
import ArgumentParser

extension ValidationError {
    
    // MARK: Initializations
    init(recoverySuggestion: String) {
        self.init("\n\(recoverySuggestion)\n")
    }
}
