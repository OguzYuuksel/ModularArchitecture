// Project: ModularArchitecture
// File: Package.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import ArgumentParser
import Foundation

@main
struct ModularArchitecture: ParsableCommand {
    
    // MARK: Static Properties
    static let configuration = CommandConfiguration(
        abstract: "A tool that automates Modular Architecture.",
        version: "0.1.0",
        subcommands: [CreateProject.self, CreatePackage.self],
        defaultSubcommand: CreateProject.self)
}
