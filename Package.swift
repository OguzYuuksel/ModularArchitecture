// swift-tools-version: 5.6

// Project: ModularArchitecture
// File: Package.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import PackageDescription

fileprivate let packageName: String = "ModularArchitecture"
let package = Package(
    name: packageName,
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
    ],
    targets: [
        .executableTarget(
            name: packageName,
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources",
            exclude: [
            ]
        ),
        .testTarget(
            name: "\(packageName)Tests",
            dependencies: [
                .init(stringLiteral: packageName),
            ],
            path: "Tests",
            exclude: [
            ]
        ),
    ]
)
