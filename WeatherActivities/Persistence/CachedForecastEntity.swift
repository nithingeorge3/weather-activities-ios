//
//  CachedForecastEntity.swift
//  WeatherActivities
//
//  Created by Nitin George on 15/11/2026.
//

import Foundation
import SwiftData

// MARK: - Persistence Model

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

// MARK: - Cached Domain Data

struct CachedForecast: Sendable {

    let days: [ForecastDay]

    let fetchedAt: Date
}

// MARK: - Cache Protocol

protocol ForecastCacheProtocol: Sendable {

    func load(
        for key: String
    ) async throws -> CachedForecast?

    func save(
        _ forecast: [ForecastDay],
        for key: String,
        fetchedAt: Date
    ) async throws
}

// MARK: - Cache Key

enum ForecastCacheKey {

    static func make(
        latitude: Double,
        longitude: Double,
        timeZoneID: String?
    ) -> String {

        "\(latitude.bitPattern)|\(longitude.bitPattern)|\(timeZoneID ?? "auto")"
    }
}

// MARK: - SwiftData Cache Store

@ModelActor
actor SwiftDataForecastCacheStore: ForecastCacheProtocol {

    // MARK: - Load

    func load(
        for key: String
    ) async throws -> CachedForecast? {

        let predicate = #Predicate<CachedForecastEntity> {
            $0.cacheKey == key
        }

        let descriptor = FetchDescriptor<CachedForecastEntity>(
            predicate: predicate
        )

        guard let entity = try modelContext.fetch(
            descriptor
        ).first else {
            return nil
        }

        // Convert persisted data back to domain models.
        let forecast = try JSONDecoder().decode(
            [ForecastDay].self,
            from: entity.payload
        )

        return CachedForecast(
            days: forecast,
            fetchedAt: entity.fetchedAt
        )
    }

    // MARK: - Save

    func save(
        _ forecast: [ForecastDay],
        for key: String,
        fetchedAt: Date
    ) async throws {

        // Convert domain models to persisted data.
        let payload = try JSONEncoder().encode(
            forecast
        )

        let predicate = #Predicate<CachedForecastEntity> {
            $0.cacheKey == key
        }

        let descriptor = FetchDescriptor<CachedForecastEntity>(
            predicate: predicate
        )

        if let existing = try modelContext.fetch(
            descriptor
        ).first {

            // Update existing cache.
            existing.payload = payload
            existing.fetchedAt = fetchedAt

        } else {

            // Create persistence entity only in the data layer.
            let entity = CachedForecastEntity(
                cacheKey: key,
                payload: payload,
                fetchedAt: fetchedAt
            )

            modelContext.insert(entity)
        }

        try modelContext.save()
    }
}

// MARK: - Forecast Load Policy

enum ForecastLoadPolicy: Sendable, Equatable {
    case regular
    case refresh
}
