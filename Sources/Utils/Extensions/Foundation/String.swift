// Project: ModularArchitecture
// File: String.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation

extension String {
    
    func lowercasedFirst() -> Self {
        guard let firstElement = self.first else {
            return self
        }
        return firstElement.lowercased() + self.dropFirst()
    }
    
    func uppercasedFirst() -> Self {
        guard let firstElement = self.first else {
            return self
        }
        return firstElement.uppercased() + self.dropFirst()
    }
    
    func replacingOccurrences(matchingPattern pattern: String, replacementProvider: (String) -> String?) -> String {
        let expression = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = expression.matches(in: self, options: [], range: NSRange(startIndex..<endIndex, in: self))
        return matches.reversed().reduce(into: self) { (current, result) in
            let range = Range(result.range, in: current)!
            let token = String(current[range])
            guard let replacement = replacementProvider(token) else { return }
            current.replaceSubrange(range, with: replacement)
        }
    }
}
