//
//  CitySearchSnapshotTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import SwiftUI
import XCTest
import SnapshotTesting
@testable import WeatherActivities

final class CitySearchSnapshotTests: XCTestCase {

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

extension CitySearchSnapshotTests {

    @MainActor
    func testCitySearchResults() async {

        let viewModel = CitySearchViewModel(
            searchCitiesUseCase: SnapshotSearchCitiesUseCase()
        )

        viewModel.query = "London"

        await viewModel.search()

        guard case .results = viewModel.state else {
            XCTFail("Expected city search results")
            return
        }

        let view = NavigationStack {
            CitySearchView(viewModel: viewModel)
        }
        .environment(
            \.locale,
            Locale(identifier: "en_GB")
        )
        .preferredColorScheme(.light)

        let controller = UIHostingController(
            rootView: view
        )

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhoneX),
            named: "results"
        )
    }
}

// MARK: - Mock

private struct SnapshotSearchCitiesUseCase:
    SearchCitiesUseCaseProtocol {

    func execute(query: String) async throws -> [CityDomain] {

        [
            CityDomain(
                id: 2643743,
                name: "London",
                country: "United Kingdom",
                region: "England",
                latitude: 51.5085,
                longitude: -0.1257,
                timeZoneID: "Europe/London"
            ),

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
    }
}
