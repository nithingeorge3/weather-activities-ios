//
//  CityRepositoryTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class CityRepositoryTests: XCTestCase {

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

extension CityRepositoryTests {

    // MARK: - Mapping

    @MainActor
    func testSearchCitiesMapsDTOToDomain() async throws {

        let cityDTO = CityDTO(
            id: 2643743,
            name: "London",
            latitude: 51.5085,
            longitude: -0.1257,
            country: "United Kingdom",
            admin1: "England",
            timezone: "Europe/London"
        )

        let service = MockCityService(
            cities: [cityDTO]
        )

        let repository = CityRepository(
            service: service
        )

        let cities = try await repository.searchCities(
            query: "London"
        )

        let city = cities.first

        let count = cities.count
        let id = city?.id
        let name = city?.name
        let country = city?.country
        let region = city?.region
        let timeZoneID = city?.timeZoneID

        XCTAssertEqual(count, 1)
        XCTAssertEqual(id, 2643743)
        XCTAssertEqual(name, "London")
        XCTAssertEqual(country, "United Kingdom")
        XCTAssertEqual(region, "England")
        XCTAssertEqual(timeZoneID, "Europe/London")
    }

    // MARK: - Optional Fields

    @MainActor
    func testSearchCitiesHandlesMissingOptionalFields() async throws {

        let cityDTO = CityDTO(
            id: 123,
            name: "Test City",
            latitude: 50.0,
            longitude: -1.0,
            country: nil,
            admin1: nil,
            timezone: nil
        )

        let service = MockCityService(
            cities: [cityDTO]
        )

        let repository = CityRepository(
            service: service
        )

        let cities = try await repository.searchCities(
            query: "Test City"
        )

        let city = cities.first

        let country = city?.country
        let region = city?.region
        let timeZoneID = city?.timeZoneID

        XCTAssertEqual(country, "")
        XCTAssertNil(region)
        XCTAssertNil(timeZoneID)
    }

    // MARK: - Empty

    @MainActor
    func testSearchCitiesReturnsEmptyArray() async throws {

        let service = MockCityService(
            cities: []
        )

        let repository = CityRepository(
            service: service
        )

        let cities = try await repository.searchCities(
            query: "UnknownCity"
        )

        let isEmpty = cities.isEmpty

        XCTAssertTrue(isEmpty)
    }

    // MARK: - Error

    @MainActor
    func testSearchCitiesPropagatesServiceError() async {

        let service = MockCityService(
            shouldFail: true
        )

        let repository = CityRepository(
            service: service
        )

        do {
            _ = try await repository.searchCities(
                query: "London"
            )

            XCTFail("Expected service error")

        } catch MockCityServiceError.failed {
            // Expected error.

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Mock

@MainActor
private final class MockCityService: CityServiceProtocol {

    private let cities: [CityDTO]
    private let shouldFail: Bool

    init(
        cities: [CityDTO] = [],
        shouldFail: Bool = false
    ) {
        self.cities = cities
        self.shouldFail = shouldFail
    }

    func searchCities(query: String) async throws -> [CityDTO] {

        if shouldFail {
            throw MockCityServiceError.failed
        }

        return cities
    }
}

private enum MockCityServiceError: Error {
    case failed
}
