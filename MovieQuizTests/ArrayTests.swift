//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Timur Tufatulin on 15/07/2024.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 2, 5, 40, 112]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 5)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 2, 5, 40, 112]
        // When
        let value = array[safe: 5]
        // Then
        XCTAssertNil(value)
    }
}
