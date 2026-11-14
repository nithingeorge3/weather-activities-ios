//
//  ActivityRecommendationRowViewData.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

import Foundation

struct ActivityRecommendationRowViewData: Identifiable, Sendable {

    let id: String

    let title: String

    let score: Int

    let bestDay: String

    let explanation: String
}

extension ActivityRecommendation {

    func toPresentation() -> ActivityRecommendationRowViewData {

        ActivityRecommendationRowViewData(
            id: activity.rawValue,
            title: activity.displayTitle,
            score: score,
            bestDay: formattedBestDay,
            explanation: explanation
        )
    }
}

// MARK: - Date Formatting

private extension ActivityRecommendation {

    var formattedBestDay: String {

        guard !bestDay.isEmpty else {
            return "Not available"
        }

        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.calendar = Calendar(identifier: .gregorian)
        parser.timeZone = TimeZone(secondsFromGMT: 0)
        parser.dateFormat = "yyyy-MM-dd"

        guard let date = parser.date(from: bestDay) else {
            return bestDay
        }

        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM")

        return formatter.string(from: date)
    }
}

// MARK: - Activity Title

private extension ActivityType {

    var displayTitle: String {
        switch self {
        case .skiing:
            return "Skiing"

        case .surfing:
            return "Surfing"

        case .outdoorSightseeing:
            return "Outdoor sightseeing"

        case .indoorSightseeing:
            return "Indoor sightseeing"
        }
    }
}
