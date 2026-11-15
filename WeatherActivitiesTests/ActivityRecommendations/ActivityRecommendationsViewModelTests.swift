//
//  ActivityRecommendationsViewModelTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class ActivityRecommendationsViewModelTests: XCTestCase {

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

extension ActivityRecommendationsViewModelTests {

    // MARK: - Initial State

    @MainActor
    func testInitialStateIsIdle() {

        let viewModel = makeViewModel()

        guard case .idle = viewModel.state else {
            XCTFail("Expected idle state")
            return
        }
    }

    // MARK: - Success

    @MainActor
    func testLoadSuccessReturnsRecommendations() async {

        let recommendation = makeRecommendation()

        let viewModel = makeViewModel(
            recommendations: [recommendation]
        )

        await viewModel.load()

        guard case .results(let activities) = viewModel.state else {
            XCTFail("Expected results state")
            return
        }

        let count = activities.count
        let title = activities.first?.title
        let score = activities.first?.score

        XCTAssertEqual(count, 1)
        XCTAssertEqual(title, "Skiing")
        XCTAssertEqual(score, 85)
    }

    // MARK: - Empty

    @MainActor
    func testEmptyResponseSetsEmptyState() async {

        let viewModel = makeViewModel(
            recommendations: []
        )

        await viewModel.load()

        guard case .empty = viewModel.state else {
            XCTFail("Expected empty state")
            return
        }
    }

    // MARK: - Error

    @MainActor
    func testLoadFailureSetsErrorState() async {

        let viewModel = makeViewModel(
            shouldFail: true
        )

        await viewModel.load()

        guard case .error(let message) = viewModel.state else {
            XCTFail("Expected error state")
            return
        }

        XCTAssertFalse(message.isEmpty)
    }
}

// MARK: - Helpers

private extension ActivityRecommendationsViewModelTests {

    @MainActor
    func makeViewModel(
        recommendations: [ActivityRecommendation] = [],
        shouldFail: Bool = false
    ) -> ActivityRecommendationsViewModel {

        let useCase = MockGetActivityRecommendationsUseCase(
            recommendations: recommendations,
            shouldFail: shouldFail
        )

        return ActivityRecommendationsViewModel(
            cityName: "London",
            latitude: 51.5085,
            longitude: -0.1257,
            timeZoneID: "Europe/London",
            useCase: useCase
        )
    }

    func makeRecommendation() -> ActivityRecommendation {

        ActivityRecommendation(
            activity: .skiing,
            score: 85,
            bestDay: "2026-11-15",
            explanation: "Snow is forecast."
        )
    }
}

// MARK: - Mock

private struct MockGetActivityRecommendationsUseCase:
    GetActivityRecommendationsUseCaseProtocol {

    let recommendations: [ActivityRecommendation]
    let shouldFail: Bool

    func execute(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?,
        policy: ForecastLoadPolicy
    ) async throws -> [ActivityRecommendation] {

        if shouldFail {
            throw MockRecommendationsError.failed
        }

        return recommendations
    }
}

private enum MockRecommendationsError: Error {
    case failed
}
