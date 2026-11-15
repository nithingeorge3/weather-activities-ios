//
//  WeatherPersistence.swift
//  WeatherActivities
//
//  Created by Nitin George on 15/11/2026.
//

import SwiftData

enum WeatherPersistence {

    // MARK: - Cache Factory

    static func makeForecastCache() -> (any ForecastCacheProtocol)? {

        do {

            let modelContainer = try makeModelContainer()

            return SwiftDataForecastCacheStore(
                modelContainer: modelContainer
            )

        } catch {

            // Caching is optional; the app can use the API.
            debugLog(
                "Forecast cache unavailable: \(error)"
            )

            return nil
        }
    }

    // MARK: - Model Container

    private static func makeModelContainer() throws -> ModelContainer {

        do {

            // Persistent storage for cached forecasts.
            return try ModelContainer(
                for: CachedForecastEntity.self
            )

        } catch {

            debugLog(
                "Persistent storage unavailable: \(error)"
            )

            // Temporary cache if disk persistence is unavailable.
            let configuration = ModelConfiguration(
                isStoredInMemoryOnly: true
            )

            return try ModelContainer(
                for: CachedForecastEntity.self,
                configurations: configuration
            )
        }
    }
}
