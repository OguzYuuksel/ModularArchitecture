// Project: ModularArchitecture - Tests
// File: PathTests.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import XCTest
import ArgumentParser
@testable import ModularArchitecture

final class PathTests: XCTestCase {
    
    // MARK: Properties
    private let decodedTilde = FileManager.default.homeDirectoryForCurrentUser.path
    
    // MARK: Functions
    // Failure Cases
    func test_Init_ThrowsInvalidCharacters_WhenContainsColon() throws {
        do {
            let _ = try Path(":")
        } catch let error as ValidationError {
            XCTAssertEqual(error.message, Path.Error.invalidCharacters.validationError.message)
            return
        }
        XCTFail("Path should have been returned a ValidationError")
    }
    
    func test_Init_ThrowsInvalidCharacters_WhenContainsColonAndText() throws {
        do {
            let _ = try Path(":ThisIsTestText")
        } catch let error as ValidationError {
            XCTAssertEqual(error.message, Path.Error.invalidCharacters.validationError.message)
            return
        }
        XCTFail("Path should have been returned a ValidationError")
    }
    
    func test_Init_ThrowsInvalidCharacters_WhenContainsTextAndColon() throws {
        do {
            let _ = try Path("ThisIsTestText:")
        } catch let error as ValidationError {
            XCTAssertEqual(error.message, Path.Error.invalidCharacters.validationError.message)
            return
        }
        XCTFail("Path should have been returned a ValidationError")
    }
    
    func test_Init_ThrowsInvalidCharacters_WhenContainsSlashAndDot() throws {
        do {
            let _ = try Path("/Users/OguzYuksel/.Test")
        } catch let error as ValidationError {
            XCTAssertEqual(error.message, Path.Error.invalidCharacters.validationError.message)
            return
        }
        XCTFail("Path should have been returned a ValidationError")
    }
    
    func test_Init_ThrowsInvalidCharacters_WhenPathDoesNotBeginWithTilde() throws {
        do {
            let _ = try Path("/Test")
        } catch let error as ValidationError {
            XCTAssertEqual(error.message, Path.Error.invalidPath.validationError.message)
            return
        }
        XCTFail("Path should have been returned a ValidationError")
    }

    // Success Cases
    func test_Init_Success_WhenPathBeginsWithTilde() throws {
        XCTAssertNoThrow(try Path("\(decodedTilde)/This/Is/Test/Path"))
    }
    
}
