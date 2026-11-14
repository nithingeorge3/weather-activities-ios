//
//  ForecastService.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

protocol ForecastServiceProtocol: Sendable {

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> ForecastResponseDTO
}

enum ForecastServiceError: Error {
    case invalidURL
}

struct ForecastService: ForecastServiceProtocol {

    private let httpClient: any HTTPClientProtocol

    init(httpClient: any HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    func getForecast(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> ForecastResponseDTO {

        var components = URLComponents()

        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"

        components.queryItems = [
            URLQueryItem(
                name: "latitude",
                value: String(latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(longitude)
            ),
            URLQueryItem(
                name: "daily",
                value: [
                    "temperature_2m_max",
                    "temperature_2m_min",
                    "precipitation_sum",
                    "precipitation_probability_max",
                    "snowfall_sum",
                    "wind_speed_10m_max",
                    "weather_code"
                ].joined(separator: ",")
            ),
            URLQueryItem(
                name: "timezone",
                value: timeZoneID ?? "auto"
            ),
            URLQueryItem(
                name: "forecast_days",
                value: "7"
            )
        ]

        guard let url = components.url else {
            throw ForecastServiceError.invalidURL
        }

        let data = try await httpClient.get(url: url)

        return try JSONDecoder().decode(
            ForecastResponseDTO.self,
            from: data
        )
    }
}
