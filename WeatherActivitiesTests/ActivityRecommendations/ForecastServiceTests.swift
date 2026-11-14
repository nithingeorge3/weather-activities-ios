//
//  ForecastServiceTests.swift
//  WeatherActivitiesTests
//
//  Created by Nitin George on 14/11/2026.
//

import XCTest
@testable import WeatherActivities

final class ForecastServiceTests: XCTestCase {

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

extension ForecastServiceTests {

    // MARK: - Request

    @MainActor
    func testForecastRequestContainsRequiredParameters() async throws {

        let data = try ForecastFixture.load("ForecastSuccess")

        let httpClient = ForecastHTTPClientSpy(data: data)

        let service = ForecastService(
            httpClient: httpClient
        )

        _ = try await service.getForecast(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        let requestedURL = await httpClient.requestedURL

        let url = try XCTUnwrap(requestedURL)

        let components = try XCTUnwrap(
            URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
        )

        let queryItems = components.queryItems ?? []

        func value(for name: String) -> String? {
            queryItems.first {
                $0.name == name
            }?.value
        }

        XCTAssertEqual(url.host, "api.open-meteo.com")
        XCTAssertEqual(url.path, "/v1/forecast")

        XCTAssertEqual(value(for: "latitude"), "51.5")
        XCTAssertEqual(value(for: "longitude"), "-0.12")
        XCTAssertEqual(value(for: "forecast_days"), "7")
        XCTAssertEqual(value(for: "timezone"), "Europe/London")

        let daily = value(for: "daily") ?? ""

        XCTAssertTrue(daily.contains("temperature_2m_max"))
        XCTAssertTrue(daily.contains("precipitation_sum"))
        XCTAssertTrue(daily.contains("snowfall_sum"))
        XCTAssertTrue(daily.contains("weather_code"))
    }

    // MARK: - Decoding

    @MainActor
    func testForecastResponseDecodesSuccessfully() async throws {

        let data = try ForecastFixture.load("ForecastSuccess")

        let service = ForecastService(
            httpClient: ForecastHTTPClientSpy(data: data)
        )

        let response = try await service.getForecast(
            latitude: 51.5,
            longitude: -0.12,
            timeZoneID: "Europe/London"
        )

        XCTAssertEqual(response.daily.time.count, 1)
        XCTAssertEqual(
            response.daily.time.first,
            "2026-11-15"
        )
    }

    // MARK: - Error

    @MainActor
    func testInvalidJSONThrowsDecodingError() async {

        let httpClient = ForecastHTTPClientSpy(
            data: Data("invalid JSON".utf8)
        )

        let service = ForecastService(
            httpClient: httpClient
        )

        do {
            _ = try await service.getForecast(
                latitude: 51.5,
                longitude: -0.12,
                timeZoneID: "Europe/London"
            )

            XCTFail("Expected decoding error")

        } catch is DecodingError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - HTTP Client Spy

private actor ForecastHTTPClientSpy: HTTPClientProtocol {

    let data: Data

    private(set) var requestedURL: URL?

    init(data: Data) {
        self.data = data
    }

    func get(url: URL) async throws -> Data {

        requestedURL = url

        return data
    }
}

// MARK: - Test Fixture Loader

enum ForecastFixture {

    static func load(_ name: String) throws -> Data {

        let bundle = Bundle(
            for: ForecastServiceTests.self
        )

        let url = try XCTUnwrap(
            bundle.url(
                forResource: name,
                withExtension: "json"
            )
        )

        return try Data(contentsOf: url)
    }
}
