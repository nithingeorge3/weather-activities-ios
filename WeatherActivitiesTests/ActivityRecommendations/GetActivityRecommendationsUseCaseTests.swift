//
//  GetActivityRecommendationsUseCaseTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class GetActivityRecommendationsUseCaseTests: XCTestCase {

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

extension GetActivityRecommendationsUseCaseTests {

    // MARK: - Ranking

    @MainActor
    func testSnowyWeatherFavoursSkiing() async throws {

        let day = makeDay(
            temperature: -2,
            snowfall: 10,
            wind: 10
        )

        let recommendations = try await getRecommendations(
            days: [day]
        )

        XCTAssertEqual(
            recommendations.first?.activity,
            .skiing
        )
    }

    @MainActor
    func testRainyWeatherFavoursIndoorSightseeing() async throws {

        let day = makeDay(
            temperature: 12,
            precipitation: 15,
            rainProbability: 95,
            wind: 10
        )

        let recommendations = try await getRecommendations(
            days: [day]
        )

        XCTAssertEqual(
            recommendations.first?.activity,
            .indoorSightseeing
        )
    }

    @MainActor
    func testClearWeatherFavoursOutdoorSightseeing() async throws {

        let day = makeDay(
            temperature: 20,
            precipitation: 0,
            wind: 8
        )

        let recommendations = try await getRecommendations(
            days: [day]
        )

        XCTAssertEqual(
            recommendations.first?.activity,
            .outdoorSightseeing
        )
    }

    @MainActor
    func testRecommendationsAreSortedByScore() async throws {

        let recommendations = try await getRecommendations(
            days: [makeDay()]
        )

        let scores = recommendations.map(\.score)

        XCTAssertEqual(recommendations.count, 4)
        XCTAssertEqual(
            scores,
            scores.sorted(by: >)
        )
    }

    // MARK: - Best Day

    @MainActor
    func testBestDaySelectsEarliestDateWhenScoresMatch() async throws {

        let laterDay = makeDay(date: "2026-11-17")
        let earlierDay = makeDay(date: "2026-11-15")

        let recommendations = try await getRecommendations(
            days: [laterDay, earlierDay]
        )

        let outdoor = recommendations.first {
            $0.activity == .outdoorSightseeing
        }

        XCTAssertEqual(
            outdoor?.bestDay,
            "2026-11-15"
        )
    }

    // MARK: - Empty and Missing Data

    @MainActor
    func testEmptyForecastReturnsNoRecommendations() async throws {

        let recommendations = try await getRecommendations(
            days: []
        )

        XCTAssertTrue(recommendations.isEmpty)
    }

    @MainActor
    func testMissingWeatherDataReturnsZeroScores() async throws {

        let day = ForecastDay(
            date: "2026-11-15",
            temperatureMax: nil,
            temperatureMin: nil,
            precipitationSum: nil,
            precipitationProbabilityMax: nil,
            snowfallSum: nil,
            windSpeedMax: nil,
            weatherCode: nil
        )

        let recommendations = try await getRecommendations(
            days: [day]
        )

        XCTAssertEqual(recommendations.count, 4)

        XCTAssertTrue(
            recommendations.allSatisfy {
                $0.score == 0 && $0.bestDay.isEmpty
            }
        )
    }
}

// MARK: - Helpers

private extension GetActivityRecommendationsUseCaseTests {

    @MainActor
    func getRecommendations(
        days: [ForecastDay]
    ) async throws -> [ActivityRecommendation] {

        let repository = MockWeatherRepository(days: days)

        let useCase = GetActivityRecommendationsUseCase(
            repository: repository
        )

        return try await useCase.execute(
            latitude: 51.5085,
            longitude: -0.1257,
            timeZoneID: "Europe/London"
        )
    }

    func makeDay(
        date: String = "2026-11-15",
        temperature: Double = 20,
        precipitation: Double = 0,
        rainProbability: Int = 0,
        snowfall: Double = 0,
        wind: Double = 10
    ) -> ForecastDay {

        ForecastDay(
            date: date,
            temperatureMax: temperature,
            temperatureMin: temperature - 5,
            precipitationSum: precipitation,
            precipitationProbabilityMax: rainProbability,
            snowfallSum: snowfall,
            windSpeedMax: wind,
            weatherCode: 0
        )
    }
}

// MARK: - Mock

private struct MockWeatherRepository: WeatherRepositoryProtocol {

    let days: [ForecastDay]

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> [ForecastDay] {

        days
    }
}
