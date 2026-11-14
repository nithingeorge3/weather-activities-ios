//
//  WeatherRepository.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

protocol WeatherRepositoryProtocol: Sendable {

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> [ForecastDay]
}

enum WeatherRepositoryError: LocalizedError {

    case inconsistentForecastData

    var errorDescription: String? {
        switch self {
        case .inconsistentForecastData:
            return "Weather forecast data is incomplete."
        }
    }
}

struct WeatherRepository: WeatherRepositoryProtocol {

    private let service: any ForecastServiceProtocol

    init(service: any ForecastServiceProtocol) {
        self.service = service
    }

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> [ForecastDay] {

        let response = try await service.getForecast(
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timeZoneID
        )

        return try mapToDomain(response.daily)
    }

    //DTO to domain
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

        guard fieldCounts.allSatisfy({ $0 == count }) else {
            throw WeatherRepositoryError.inconsistentForecastData
        }

        return (0..<count).map { index in

            ForecastDay(
                date: daily.time[index],
                temperatureMax: daily.temperatureMax[index],
                temperatureMin: daily.temperatureMin[index],
                precipitationSum: daily.precipitationSum[index],
                precipitationProbabilityMax: daily.precipitationProbabilityMax[index],
                snowfallSum: daily.snowfallSum[index],
                windSpeedMax: daily.windSpeedMax[index],
                weatherCode: daily.weatherCode[index]
            )
        }
    }
}
