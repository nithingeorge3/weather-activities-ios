//
//  CityServiceTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class CityServiceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

extension CityServiceTests {

    @MainActor
    func testSearchCitiesDecodesResponse() async throws {

        let data = try JSONFixtureLoader.load(
            "CitySearchSuccess",
            bundle: Bundle(for: CityServiceTests.self)
        )

        let httpClient = MockHTTPClient(
            data: data
        )

        let service = CityService(
            httpClient: httpClient
        )

        let cities = try await service.searchCities(
            query: "London"
        )

        let count = cities.count
        let name = cities.first?.name
        let country = cities.first?.country

        XCTAssertEqual(count, 1)
        XCTAssertEqual(name, "London")
        XCTAssertEqual(country, "United Kingdom")
    }
    
    @MainActor
    func testSearchCitiesReturnsEmptyResults() async throws {

        let data = try JSONFixtureLoader.load(
            "CitySearchEmpty",
            bundle: Bundle(for: CityServiceTests.self)
        )

        let service = CityService(
            httpClient: MockHTTPClient(data: data)
        )

        let cities = try await service.searchCities(
            query: "london"
        )

        XCTAssertTrue(cities.isEmpty)
    }
}
