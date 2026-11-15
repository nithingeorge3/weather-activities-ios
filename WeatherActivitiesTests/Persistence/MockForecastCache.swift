//
//  MockForecastCache.swift
//  WeatherActivities
//
//  Created by Nitin George on 15/11/2026.
//

import Foundation
@testable import WeatherActivities

actor MockForecastCache: ForecastCacheProtocol {

    private var storage: [String: CachedForecast] = [:]

    func load(
        for key: String
    ) async throws -> CachedForecast? {

        storage[key]
    }

    func save(
        _ forecast: [ForecastDay],
        for key: String,
        fetchedAt: Date
    ) async throws {

        storage[key] = CachedForecast(
            days: forecast,
            fetchedAt: fetchedAt
        )
    }

    // MARK: - Test Helper

    func seed(
        _ forecast: [ForecastDay],
        for key: String,
        fetchedAt: Date
    ) {

        storage[key] = CachedForecast(
            days: forecast,
            fetchedAt: fetchedAt
        )
    }
}
