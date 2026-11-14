//
//  ForecastDay.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

struct ForecastDay: Sendable, Equatable {

    let date: String

    let temperatureMax: Double?
    let temperatureMin: Double?

    let precipitationSum: Double?
    let precipitationProbabilityMax: Int?

    let snowfallSum: Double?
    let windSpeedMax: Double?

    let weatherCode: Int?
}
