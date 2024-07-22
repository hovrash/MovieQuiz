//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Timur Tufatulin on 15/07/2024.
//

import XCTest

@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testAlertExists() {
        sleep(2)
        let alert = app.alerts["Alert"]
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд закончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testAlertClosed() {
        sleep(2)
        let alert = app.alerts["Alert"]
        let indexLabel = app.staticTexts["Index"]
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()
        sleep(2)
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
