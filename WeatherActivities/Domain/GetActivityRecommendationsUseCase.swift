//
//  GetActivityRecommendationsUseCase.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

protocol GetActivityRecommendationsUseCaseProtocol: Sendable {

    func execute(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> [ActivityRecommendation]
}

struct GetActivityRecommendationsUseCase:
    GetActivityRecommendationsUseCaseProtocol {

    private let repository: any WeatherRepositoryProtocol

    init(repository: any WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) async throws -> [ActivityRecommendation] {

        let forecast = try await repository.getForecast(
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timeZoneID
        )

        try Task.checkCancellation()

        let days = Array(forecast.prefix(7))

        guard !days.isEmpty else {
            return []
        }

        let recommendations = ActivityType.allCases.map { activity in

            let candidates = days.compactMap { day
                -> (day: ForecastDay, score: Int)? in

                guard let score = score(
                    activity: activity,
                    day: day
                ) else {
                    return nil
                }

                return (day: day, score: score)
            }

            let best = candidates.sorted {
                if $0.score == $1.score {
                    return $0.day.date < $1.day.date
                }

                return $0.score > $1.score
            }.first

            return ActivityRecommendation(
                activity: activity,
                score: best?.score ?? 0,
                bestDay: best?.day.date ?? "",
                explanation: explanation(
                    for: activity,
                    day: best?.day
                )
            )
        }

        return recommendations.sorted {
            if $0.score == $1.score {
                return $0.activity.rawValue < $1.activity.rawValue
            }

            return $0.score > $1.score
        }
    }
}

// MARK: - Activity Scoring

private extension GetActivityRecommendationsUseCase {

    func score(
        activity: ActivityType,
        day: ForecastDay
    ) -> Int? {

        switch activity {
        case .skiing:
            return skiingScore(for: day)

        case .surfing:
            return surfingScore(for: day)

        case .outdoorSightseeing:
            return outdoorSightseeingScore(for: day)

        case .indoorSightseeing:
            return indoorSightseeingScore(for: day)
        }
    }

    // MARK: Skiing

    func skiingScore(for day: ForecastDay) -> Int? {

        guard
            let snow = day.snowfallSum,
            let temperature = day.temperatureMax,
            let wind = day.windSpeedMax
        else {
            return nil
        }

        let snowScore: Int

        if snow >= 5 {
            snowScore = 65
        } else if snow > 0 {
            snowScore = 35
        } else {
            snowScore = 5
        }

        let temperatureScore: Int

        if temperature <= 2 {
            temperatureScore = 20
        } else if temperature <= 6 {
            temperatureScore = 10
        } else {
            temperatureScore = 0
        }

        let windScore: Int

        if wind <= 25 {
            windScore = 15
        } else if wind <= 40 {
            windScore = 5
        } else {
            windScore = 0
        }

        let stormPenalty = isStormy(day) ? 20 : 0

        return clampedScore(
            snowScore + temperatureScore
                + windScore - stormPenalty
        )
    }

    // MARK: Surfing

    func surfingScore(for day: ForecastDay) -> Int? {

        guard
            let temperature = day.temperatureMax,
            let precipitation = day.precipitationSum,
            let wind = day.windSpeedMax
        else {
            return nil
        }

        // Weather-only estimate.
        // Wave and swell conditions are unavailable.

        let windScore: Int

        if (10.0...30.0).contains(wind) {
            windScore = 50
        } else if wind < 45 {
            windScore = 20
        } else {
            windScore = 0
        }

        let temperatureScore: Int

        if temperature >= 15 {
            temperatureScore = 25
        } else if temperature >= 8 {
            temperatureScore = 10
        } else {
            temperatureScore = 0
        }

        let precipitationScore = precipitation < 5 ? 25 : 0
        let stormPenalty = isStormy(day) ? 60 : 0

        return clampedScore(
            windScore + temperatureScore
                + precipitationScore - stormPenalty
        )
    }

    // MARK: Outdoor Sightseeing

    func outdoorSightseeingScore(for day: ForecastDay) -> Int? {

        guard
            let temperature = day.temperatureMax,
            let precipitation = day.precipitationSum,
            let wind = day.windSpeedMax
        else {
            return nil
        }

        let temperatureScore: Int

        if (10.0...25.0).contains(temperature) {
            temperatureScore = 30
        } else if (5.0...30.0).contains(temperature) {
            temperatureScore = 15
        } else {
            temperatureScore = 0
        }

        let precipitationScore: Int

        if precipitation < 1 {
            precipitationScore = 25
        } else if precipitation < 5 {
            precipitationScore = 10
        } else {
            precipitationScore = 0
        }

        let windScore: Int

        if wind < 20 {
            windScore = 10
        } else if wind < 40 {
            windScore = 5
        } else {
            windScore = 0
        }

        let rainProbabilityPenalty =
            (day.precipitationProbabilityMax ?? 0) >= 70
                ? 10 : 0

        let stormPenalty = isStormy(day) ? 35 : 0

        return clampedScore(
            35 + temperatureScore
                + precipitationScore
                + windScore
                - rainProbabilityPenalty
                - stormPenalty
        )
    }

    // MARK: Indoor Sightseeing

    func indoorSightseeingScore(for day: ForecastDay) -> Int? {

        guard
            let temperature = day.temperatureMax,
            let precipitation = day.precipitationSum,
            let wind = day.windSpeedMax
        else {
            return nil
        }

        let precipitationScore: Int

        if precipitation >= 10 {
            precipitationScore = 30
        } else if precipitation >= 3 {
            precipitationScore = 20
        } else {
            precipitationScore = 5
        }

        let windScore = wind >= 35 ? 15 : 0

        let temperatureScore =
            temperature < 5 || temperature > 30 ? 15 : 0

        let stormScore = isStormy(day) ? 15 : 0

        return clampedScore(
            45 + precipitationScore
                + windScore
                + temperatureScore
                + stormScore
        )
    }
}

// MARK: - Helpers

private extension GetActivityRecommendationsUseCase {

    func isStormy(_ day: ForecastDay) -> Bool {
        guard let code = day.weatherCode else {
            return false
        }

        return (95...99).contains(code)
    }

    func clampedScore(_ value: Int) -> Int {
        min(100, max(0, value))
    }
}

// MARK: - Recommendation Messages

private extension GetActivityRecommendationsUseCase {

    func explanation(
        for activity: ActivityType,
        day: ForecastDay?
    ) -> String {

        guard let day else {
            return "Not enough weather data available."
        }

        switch activity {

        case .skiing:

            if (day.snowfallSum ?? 0) < 1 {
                return "Little new snow expected. Check resort conditions."
            }

            return "Snow is forecast. Check local ski conditions."

        case .surfing:

            if isStormy(day) {
                return "Stormy weather expected. Wave conditions are unknown."
            }

            return "Weather-only estimate. Wave conditions are unknown."

        case .outdoorSightseeing:

            if (day.precipitationSum ?? 0) >= 5 {
                return "Rain may affect outdoor activities."
            }

            if (day.windSpeedMax ?? 0) >= 40 {
                return "Strong winds may affect outdoor activities."
            }

            if let temperature = day.temperatureMax,
               temperature < 5 || temperature > 30 {
                return "Temperatures may be uncomfortable outdoors."
            }

            return "Good weather for outdoor sightseeing."

        case .indoorSightseeing:

            if (day.precipitationSum ?? 0) >= 3 {
                return "Rain makes indoor activities a good choice."
            }

            if (day.windSpeedMax ?? 0) >= 35 {
                return "Windy weather favours indoor activities."
            }

            return "A good alternative to outdoor activities."
        }
    }
}
