//
//  SearchCitiesUseCaseTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class SearchCitiesUseCaseTests: XCTestCase {

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

extension SearchCitiesUseCaseTests {

    // MARK: - Success

    @MainActor
    func testExecuteTrimsQueryBeforeSearching() async throws {

        let repository = MockCityRepository()

        let useCase = SearchCitiesUseCase(
            repository: repository
        )

        _ = try await useCase.execute(
            query: "  London  "
        )

        let receivedQuery = repository.receivedQuery

        XCTAssertEqual(receivedQuery, "London")
    }

    // MARK: - Validation

    @MainActor
    func testExecuteRejectsShortQuery() async {

        let repository = MockCityRepository()

        let useCase = SearchCitiesUseCase(
            repository: repository
        )

        do {
            _ = try await useCase.execute(
                query: " L "
            )

            XCTFail("Expected queryTooShort error")

        } catch SearchCitiesError.queryTooShort {
            // Expected error.

        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let receivedQuery = repository.receivedQuery

        XCTAssertNil(receivedQuery)
    }

    // MARK: - Error

    @MainActor
    func testExecutePropagatesRepositoryError() async {

        let repository = MockCityRepository(
            shouldFail: true
        )

        let useCase = SearchCitiesUseCase(
            repository: repository
        )

        do {
            _ = try await useCase.execute(
                query: "London"
            )

            XCTFail("Expected repository error")

        } catch MockRepositoryError.failed {
            // Expected error.

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Mock

@MainActor
private final class MockCityRepository: CityRepositoryProtocol {

    private(set) var receivedQuery: String?

    private let shouldFail: Bool

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func searchCities(query: String) async throws -> [CityDomain] {

        receivedQuery = query

        if shouldFail {
            throw MockRepositoryError.failed
        }

        return []
    }
}

private enum MockRepositoryError: Error {
    case failed
}
