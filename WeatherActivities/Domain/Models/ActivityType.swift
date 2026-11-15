//
//  ActivityType.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

enum ActivityType: String, CaseIterable, Sendable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing
}

struct ActivityRecommendation: Identifiable, Sendable {
    let activity: ActivityType
    let score: Int
    let bestDay: String
    let explanation: String

    var id: ActivityType {
        activity
    }
}
