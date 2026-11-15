//
//  CitySearchViewModelTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
import InlineSnapshotTesting
@testable import WeatherActivities

final class CitySearchViewModelTests: XCTestCase {

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

extension CitySearchViewModelTests {

    // MARK: - Validation

    @MainActor
    func testCanSearchRequiresAtLeastTwoCharacters() async {

        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.canSearch)

        viewModel.query = " L "
        XCTAssertFalse(viewModel.canSearch)

        viewModel.query = " Lo "
        XCTAssertTrue(viewModel.canSearch)
    }

    @MainActor
    func testInvalidQueryDoesNotStartSearch() async {

        let viewModel = makeViewModel(
            shouldFail: true
        )

        viewModel.query = "L"

        await viewModel.search()

        guard case .idle = viewModel.state else {
            XCTFail("Expected idle state for an invalid query")
            return
        }
    }

    // MARK: - Success

    @MainActor
    func testSearchSuccessReturnsCityResults() async {

        let city = makeCity()

        let viewModel = makeViewModel(
            cities: [city]
        )

        viewModel.query = "London"

        await viewModel.search()

        guard case .results(let cities) = viewModel.state else {
            XCTFail("Expected results state")
            return
        }

        let count = cities.count
        let id = cities.first?.id
        let title = cities.first?.title

        XCTAssertEqual(count, 1)
        XCTAssertEqual(id, 2643743)
        XCTAssertEqual(title, "London")
    }

    // MARK: - Empty

    @MainActor
    func testSearchEmptyResponseSetsEmptyState() async {

        let viewModel = makeViewModel()

        viewModel.query = "UnknownCity"

        await viewModel.search()

        guard case .empty = viewModel.state else {
            XCTFail("Expected empty state")
            return
        }
    }

    // MARK: - Error

    @MainActor
    func testSearchFailureSetsErrorState() async {

        let viewModel = makeViewModel(
            shouldFail: true
        )

        viewModel.query = "London"

        await viewModel.search()

        guard case .error(let message) = viewModel.state else {
            XCTFail("Expected error state")
            return
        }

        XCTAssertFalse(message.isEmpty)
    }
}

// MARK: - Test Helpers

private extension CitySearchViewModelTests {

    @MainActor
    func makeViewModel(
        cities: [CityDomain] = [],
        shouldFail: Bool = false
    ) -> CitySearchViewModel {

        let useCase = MockSearchCitiesUseCase(
            cities: cities,
            shouldFail: shouldFail
        )

        return CitySearchViewModel(
            searchCitiesUseCase: useCase
        )
    }

    @MainActor
    func makeCity() -> CityDomain {

        CityDomain(
            id: 2643743,
            name: "London",
            country: "United Kingdom",
            region: "England",
            latitude: 51.5085,
            longitude: -0.1257,
            timeZoneID: "Europe/London"
        )
    }
}

// MARK: - Mock

private struct MockSearchCitiesUseCase: SearchCitiesUseCaseProtocol {

    let cities: [CityDomain]
    let shouldFail: Bool

    func execute(query: String) async throws -> [CityDomain] {

        if shouldFail {
            throw MockSearchError.failed
        }

        return cities
    }
}

//MARK: -  InlineSnapshot

extension CitySearchViewModelTests {

    /// Verifies city result ordering and subtitle formatting.
    @MainActor
    func testSearchResultsInlineSnapshot() async {

        let viewModel = makeViewModel(
            cities: [
                makeCity(),
                CityDomain(
                    id: 6058560,
                    name: "London",
                    country: "Canada",
                    region: "Ontario",
                    latitude: 42.9849,
                    longitude: -81.2453,
                    timeZoneID: "America/Toronto"
                )
            ]
        )

        viewModel.query = "London"

        await viewModel.search()

        guard case .results(let cities) = viewModel.state else {
            XCTFail("Expected results state")
            return
        }

        let summary = cities.map {
            "\($0.title) - \($0.subtitle)"
        }
        .joined(separator: "\n")

        assertInlineSnapshot(
            of: summary,
            as: .description
        ) {
            """
            London - England, United Kingdom
            London - Ontario, Canada
            """
        }
    }
}

private enum MockSearchError: Error {
    case failed
}
