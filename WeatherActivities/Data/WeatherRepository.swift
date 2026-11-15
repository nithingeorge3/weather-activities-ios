//
//  WeatherRepository.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

// MARK: - Repository Protocol

protocol WeatherRepositoryProtocol: Sendable {

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?,
        policy: ForecastLoadPolicy
    ) async throws -> [ForecastDay]
}

// MARK: - Errors

enum WeatherRepositoryError: LocalizedError {

    case inconsistentForecastData

    var errorDescription: String? {

        switch self {

        case .inconsistentForecastData:
            return "Weather forecast data is incomplete."
        }
    }
}

// MARK: - Weather Repository

struct WeatherRepository: WeatherRepositoryProtocol {

    private let service: any ForecastServiceProtocol
    private let cache: (any ForecastCacheProtocol)?
    private let cacheMaxAge: TimeInterval
    private let now: @Sendable () -> Date

    init(
        service: any ForecastServiceProtocol,
        cache: (any ForecastCacheProtocol)?,
        cacheMaxAge: TimeInterval = 6 * 60 * 60,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {

        self.service = service
        self.cache = cache
        self.cacheMaxAge = cacheMaxAge
        self.now = now
    }

    // MARK: - Default Forecast

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> [ForecastDay] {

        try await getForecast(
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timeZoneID,
            policy: .regular
        )
    }

    // MARK: - Forecast With Cache Policy

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?,
        policy: ForecastLoadPolicy
    ) async throws -> [ForecastDay] {

        let cacheKey = ForecastCacheKey.make(
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timeZoneID
        )

        do {

            // fetch the latest forecast from the API
            let response = try await service.getForecast(
                latitude: latitude,
                longitude: longitude,
                timeZoneID: timeZoneID
            )

            try Task.checkCancellation()

            // convert API DTOs to domain models
            let forecast = try mapToDomain(
                response.daily
            )

            // local caching
            if !forecast.isEmpty, let cache {

                do {

                    try await cache.save(
                        forecast,
                        for: cacheKey,
                        fetchedAt: now()
                    )

                } catch is CancellationError {

                    throw CancellationError()

                } catch {

                    // Cache failure must not hide valid API data
                    debugLog(
                        "Forecast cache save failed: \(error)"
                    )
                }
            }

            try Task.checkCancellation()

            return forecast

        } catch is CancellationError {

            throw CancellationError()

        } catch let error as WeatherRepositoryError {

            //inconsistent API data with cached data.
            throw error

        } catch {

            let originalError = error

            try Task.checkCancellation()

            //refresh must report failures to the ViewModel

            guard policy == .regular else {
                throw originalError
            }

            //attempt to retrieve the cached forecast
            guard let cache,
                  let cached = try? await cache.load(
                    for: cacheKey
                  ) else {

                throw originalError
            }

            try Task.checkCancellation()

            //validate cache freshness
            let cacheAge = now().timeIntervalSince(
                cached.fetchedAt
            )

            guard cacheAge >= 0,
                  cacheAge <= cacheMaxAge,
                  !cached.days.isEmpty else {

                throw originalError
            }

            //return cached domain models
            return cached.days
        }
    }

    // MARK: - DTO to Domain

    private func mapToDomain(
        _ daily: DailyForecastDTO
    ) throws -> [ForecastDay] {

        let count = daily.time.count

        let fieldCounts = [
            daily.temperatureMax.count,
            daily.temperatureMin.count,
            daily.precipitationSum.count,
            daily.precipitationProbabilityMax.count,
            daily.snowfallSum.count,
            daily.windSpeedMax.count,
            daily.weatherCode.count
        ]

        guard fieldCounts.allSatisfy({
            $0 == count
        }) else {

            throw WeatherRepositoryError.inconsistentForecastData
        }

        return (0..<count).map { index in

            ForecastDay(
                date: daily.time[index],
                temperatureMax: daily.temperatureMax[index],
                temperatureMin: daily.temperatureMin[index],
                precipitationSum: daily.precipitationSum[index],
                precipitationProbabilityMax:
                    daily.precipitationProbabilityMax[index],
                snowfallSum: daily.snowfallSum[index],
                windSpeedMax: daily.windSpeedMax[index],
                weatherCode: daily.weatherCode[index]
            )
        }
    }
}
