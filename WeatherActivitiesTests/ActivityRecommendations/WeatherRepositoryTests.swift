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
            service: service,
            cache: nil
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
            ),
            cache: nil
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
            ),
            cache: nil
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

//MARK: - persistence
extension WeatherRepositoryTests {

    // MARK: - Cache Save

    @MainActor
    func testSuccessfulForecastIsSavedToCache() async throws {

        let dto = try makeForecastDTO()

        let cache = MockForecastCache()

        let fixedDate = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        let repository = WeatherRepository(
            service: MockForecastService(
                response: dto,
                shouldFail: false
            ),
            cache: cache,
            now: { fixedDate }
        )

        let days = try await repository.getForecast(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London",
            policy: .regular
        )

        let key = ForecastCacheKey.make(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        let cached = try await cache.load(
            for: key
        )

        let result = try XCTUnwrap(cached)

        XCTAssertEqual(days.count, 1)

        XCTAssertEqual(result.days.count, 1)

        XCTAssertEqual(
            result.days.first?.date,
            "2026-11-15"
        )

        XCTAssertEqual(
            result.fetchedAt,
            fixedDate
        )
    }

    // MARK: - Cache Fallback

    @MainActor
    func testNetworkFailureReturnsFreshCachedForecast() async throws {

        let dto = try makeForecastDTO()

        let cache = MockForecastCache()

        let fixedDate = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        let key = ForecastCacheKey.make(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        let cachedDay = makeCachedForecastDay()

        await cache.seed(
            [cachedDay],
            for: key,
            fetchedAt: fixedDate.addingTimeInterval(-3600)
        )

        let repository = WeatherRepository(
            service: MockForecastService(
                response: dto,
                shouldFail: true
            ),
            cache: cache,
            now: { fixedDate }
        )

        let days = try await repository.getForecast(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London",
            policy: .regular
        )

        XCTAssertEqual(days.count, 1)

        XCTAssertEqual(
            days.first?.date,
            "2026-11-15"
        )
    }

    // MARK: - Refresh

    @MainActor
    func testRefreshDoesNotFallBackToCache() async throws {

        let dto = try makeForecastDTO()

        let cache = MockForecastCache()

        let fixedDate = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        let key = ForecastCacheKey.make(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        await cache.seed(
            [makeCachedForecastDay()],
            for: key,
            fetchedAt: fixedDate
        )

        let repository = WeatherRepository(
            service: MockForecastService(
                response: dto,
                shouldFail: true
            ),
            cache: cache,
            now: { fixedDate }
        )

        do {

            _ = try await repository.getForecast(
                latitude: 51.5,
                longitude: -0.12,
                timeZoneID: "Europe/London",
                policy: .refresh
            )

            XCTFail("Expected refresh to report the network failure")

        } catch is MockForecastError {

            // Expected.

        } catch {

            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Expired Cache

    @MainActor
    func testExpiredCacheIsNotUsed() async throws {

        let dto = try makeForecastDTO()

        let cache = MockForecastCache()

        let fixedDate = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        let key = ForecastCacheKey.make(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        // Seven hours old; exceeds the six-hour cache limit.
        await cache.seed(
            [makeCachedForecastDay()],
            for: key,
            fetchedAt: fixedDate.addingTimeInterval(-7 * 3600)
        )

        let repository = WeatherRepository(
            service: MockForecastService(
                response: dto,
                shouldFail: true
            ),
            cache: cache,
            cacheMaxAge: 6 * 3600,
            now: { fixedDate }
        )

        do {

            _ = try await repository.getForecast(
                latitude: 51.5,
                longitude: -0.12,
                timeZoneID: "Europe/London",
                policy: .regular
            )

            XCTFail("Expected the original network error")

        } catch is MockForecastError {

            // Expected.

        } catch {

            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Cache Test Fixture

private extension WeatherRepositoryTests {

    func makeCachedForecastDay() -> ForecastDay {

        ForecastDay(
            date: "2026-11-15",
            temperatureMax: 12.5,
            temperatureMin: 6.2,
            precipitationSum: 3.0,
            precipitationProbabilityMax: 60,
            snowfallSum: 0.0,
            windSpeedMax: 18.0,
            weatherCode: 61
        )
    }
}
