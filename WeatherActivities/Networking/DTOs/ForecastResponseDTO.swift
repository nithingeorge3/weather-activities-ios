//
//  ForecastResponseDTO.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

import Foundation

struct ForecastResponseDTO: Decodable, Sendable {

    let daily: DailyForecastDTO
}

struct DailyForecastDTO: Decodable, Sendable {

    let time: [String]

    let temperatureMax: [Double?]
    let temperatureMin: [Double?]

    let precipitationSum: [Double?]
    let precipitationProbabilityMax: [Int?]

    let snowfallSum: [Double?]
    let windSpeedMax: [Double?]

    let weatherCode: [Int?]

    enum CodingKeys: String, CodingKey {

        case time

        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"

        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"

        case snowfallSum = "snowfall_sum"
        case windSpeedMax = "wind_speed_10m_max"

        case weatherCode = "weather_code"
    }
}
