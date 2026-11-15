//
//  CachedForecastEntity.swift
//  WeatherActivities
//
//  Created by Nitin George on 15/11/2026.
//

import Foundation
import SwiftData

@Model
final class CachedForecastEntity {
    @Attribute(.unique)
    var cacheKey: String
    var payload: Data
    var fetchedAt: Date

    init(
        cacheKey: String,
        payload: Data,
        fetchedAt: Date
    ) {
        self.cacheKey = cacheKey
        self.payload = payload
        self.fetchedAt = fetchedAt
    }
}
