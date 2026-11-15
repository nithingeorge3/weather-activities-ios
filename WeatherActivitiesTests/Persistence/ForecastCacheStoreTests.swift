//
//  ForecastCacheStoreTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 15/11/2026.
//

import XCTest
import SwiftData
@testable import WeatherActivities

final class ForecastCacheStoreTests: XCTestCase {

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

extension ForecastCacheStoreTests {

    // MARK: - Save and Load
    @MainActor
    func testSaveAndLoadForecast() async throws {

        let store = try makeStore()

        let forecast = makeForecastDay()

        let fetchedAt = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        try await store.save(
            [forecast],
            for: "london",
            fetchedAt: fetchedAt
        )

        let loaded = try await store.load(
            for: "london"
        )

        let cached = try XCTUnwrap(loaded)

        XCTAssertEqual(cached.days.count, 1)

        XCTAssertEqual(
            cached.days.first?.date,
            "2026-11-15"
        )

        XCTAssertEqual(
            cached.days.first?.temperatureMax,
            12.5
        )

        XCTAssertEqual(
            cached.days.first?.weatherCode,
            61
        )

        XCTAssertEqual(
            cached.fetchedAt,
            fetchedAt
        )
    }

    // MARK: - Update Existing Cache

    @MainActor
    func testSavingSameKeyUpdatesExistingForecast() async throws {

        let store = try makeStore()

        let original = makeForecastDay(
            date: "2026-11-15"
        )

        let updated = makeForecastDay(
            date: "2026-11-16"
        )

        let firstDate = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        let secondDate = firstDate.addingTimeInterval(
            3600
        )

        try await store.save(
            [original],
            for: "london",
            fetchedAt: firstDate
        )

        try await store.save(
            [updated],
            for: "london",
            fetchedAt: secondDate
        )

        let loaded = try await store.load(
            for: "london"
        )

        let cached = try XCTUnwrap(loaded)

        XCTAssertEqual(cached.days.count, 1)

        XCTAssertEqual(
            cached.days.first?.date,
            "2026-11-16"
        )

        XCTAssertEqual(
            cached.fetchedAt,
            secondDate
        )
    }

    // MARK: - Missing Cache

    @MainActor
    func testMissingCacheReturnsNil() async throws {

        let store = try makeStore()

        let cached = try await store.load(
            for: "unknown-city"
        )

        XCTAssertNil(cached)
    }

    // MARK: - Different Cities

    @MainActor
    func testDifferentKeysStoreSeparateForecasts() async throws {

        let store = try makeStore()

        let fetchedAt = Date(
            timeIntervalSince1970: 1_800_000_000
        )

        try await store.save(
            [makeForecastDay(date: "2026-11-15")],
            for: "london-uk",
            fetchedAt: fetchedAt
        )

        try await store.save(
            [makeForecastDay(date: "2026-11-16")],
            for: "london-canada",
            fetchedAt: fetchedAt
        )

        let uk = try await store.load(
            for: "london-uk"
        )

        let canada = try await store.load(
            for: "london-canada"
        )

        XCTAssertEqual(
            uk?.days.first?.date,
            "2026-11-15"
        )

        XCTAssertEqual(
            canada?.days.first?.date,
            "2026-11-16"
        )
    }
}

// MARK: - Helpers

private extension ForecastCacheStoreTests {

    @MainActor
    func makeStore() throws -> ForecastCacheStore {

        // Unique in-memory database for this test.
        let configuration = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: CachedForecastEntity.self,
            configurations: configuration
        )

        return ForecastCacheStore(
            modelContainer: container
        )
    }

    func makeForecastDay(
        date: String = "2026-11-15"
    ) -> ForecastDay {

        ForecastDay(
            date: date,
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
