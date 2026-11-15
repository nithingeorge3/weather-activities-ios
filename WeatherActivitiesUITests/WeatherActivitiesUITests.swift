//
//  WeatherActivitiesUITests.swift
//  WeatherActivitiesUITests
//
//  Created by Nitin George on 13/11/2026.
//

import XCTest

final class WeatherActivitiesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Launch

    @MainActor
    func testAppLaunchDisplaysCitySearch() {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.textFields["citySearch.input"]
        let searchButton = app.buttons["citySearch.searchButton"]

        //XCTAssertTrue failed
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5)
        )

        XCTAssertTrue(searchButton.exists)
    }

    // MARK: - Search Validation

    @MainActor
    func testSearchButtonDisabledForShortQuery() {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.textFields["citySearch.input"]
        let searchButton = app.buttons["citySearch.searchButton"]

        //XCTAssertTrue failed
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5)
        )

        XCTAssertFalse(searchButton.isEnabled)

        searchField.tap()
        searchField.typeText("L")

        XCTAssertFalse(searchButton.isEnabled)
    }

    @MainActor
    func testSearchButtonEnabledForValidQuery() {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.textFields["citySearch.input"]
        let searchButton = app.buttons["citySearch.searchButton"]

        //XCTAssertTrue failed
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5)
        )

        searchField.tap()
        searchField.typeText("London")

        XCTAssertTrue(searchButton.isEnabled)
    }

    // MARK: - Whitespace Validation

    @MainActor
    func testSearchButtonTrimsWhitespace() {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.textFields["citySearch.input"]
        let searchButton = app.buttons["citySearch.searchButton"]

        //XCTAssertTrue failed
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5)
        )

        searchField.tap()
        searchField.typeText(" L ")

        XCTAssertFalse(searchButton.isEnabled)

        searchField.typeText("o")

        XCTAssertTrue(searchButton.isEnabled)
    }

}
