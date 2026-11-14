//
//  WeatherRepositoryTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class WeatherRepositoryTests: XCTestCase {

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

extension WeatherRepositoryTests {

    // MARK: - Mapping

    @MainActor
    func testForecastDTOMapsToDomain() async throws {

        let dto = try makeForecastDTO()

        let service = MockForecastService(
            response: dto,
            shouldFail: false
        )

        let repository = WeatherRepository(
            service: service
        )

        let days = try await repository.getForecast(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        XCTAssertEqual(days.count, 1)

        let day = try XCTUnwrap(days.first)

        XCTAssertEqual(day.date, "2026-11-15")
        XCTAssertEqual(day.temperatureMax, 12.5)
        XCTAssertEqual(day.precipitationSum, 3.0)
        XCTAssertEqual(day.snowfallSum, 0.0)
        XCTAssertEqual(day.windSpeedMax, 18.0)
        XCTAssertEqual(day.weatherCode, 61)
    }

    // MARK: - Invalid Response

    @MainActor
    func testInconsistentForecastDataThrowsError() async throws {

        let json = """
        {
            "daily": {
                "time": ["2026-11-15"],
                "temperature_2m_max": [12.5],
                "temperature_2m_min": [6.2],
                "precipitation_sum": [3.0],
                "precipitation_probability_max": [60],
                "snowfall_sum": [0.0],
                "wind_speed_10m_max": [],
                "weather_code": [61]
            }
        }
        """

        let dto = try JSONDecoder().decode(
            ForecastResponseDTO.self,
            from: Data(json.utf8)
        )

        let repository = WeatherRepository(
            service: MockForecastService(
                response: dto,
                shouldFail: false
            )
        )

        do {
            _ = try await repository.getForecast(
                latitude: 51.5,
                longitude: -0.12,
                timeZoneID: "Europe/London"
            )

            XCTFail("Expected inconsistent forecast data error")

        } catch WeatherRepositoryError.inconsistentForecastData {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Service Error

    @MainActor
    func testServiceErrorIsPropagated() async throws {

        let dto = try makeForecastDTO()

        let repository = WeatherRepository(
            service: MockForecastService(
                response: dto,
                shouldFail: true
            )
        )

        do {
            _ = try await repository.getForecast(
                latitude: 51.5,
                longitude: -0.12,
                timeZoneID: "Europe/London"
            )

            XCTFail("Expected service error")

        } catch is MockForecastError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Helpers

private extension WeatherRepositoryTests {

    @MainActor
    func makeForecastDTO() throws -> ForecastResponseDTO {

        let data = try ForecastFixture.load(
            "ForecastSuccess"
        )

        return try JSONDecoder().decode(
            ForecastResponseDTO.self,
            from: data
        )
    }
}

// MARK: - Mock

private struct MockForecastService: ForecastServiceProtocol {

    let response: ForecastResponseDTO
    let shouldFail: Bool

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> ForecastResponseDTO {

        if shouldFail {
            throw MockForecastError.failed
        }

        return response
    }
}

private enum MockForecastError: Error {
    case failed
}
