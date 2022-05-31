// Project: ModularArchitecture
// File: StringProtocol.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation

extension StringProtocol {

    func consistsOf(_ characters: CharacterSet) -> Bool {
        guard !self.isEmpty else {
            return false
        }
        
        return self.unicodeScalars.allSatisfy { characters.contains($0) }
    }

    var numberOfLines: Int {
        return self.numberOfOccurrencesOf(CharacterSet(charactersIn: "\n")) + 1
    }

    func numberOfOccurrencesOf(_ input: CharacterSet) -> Int {
        return self.components(separatedBy: input).count - 1
    }
    
}
