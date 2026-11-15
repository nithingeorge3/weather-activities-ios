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

    // MARK: - Private Helpers

    private func fetchEntity(
        for key: String
    ) throws -> CachedForecastEntity? {

        let predicate = #Predicate<CachedForecastEntity> {
            $0.cacheKey == key
        }

        let descriptor = FetchDescriptor<CachedForecastEntity>(
            predicate: predicate
        )

        return try modelContext.fetch(descriptor).first
    }
}

// MARK: - Cache Operations

extension SwiftDataForecastCacheStore {

    // MARK: - Load

    func load(
        for key: String
    ) async throws -> CachedForecast? {

        guard let entity = try fetchEntity(
            for: key
        ) else {
            return nil
        }

        //convert persisted data back to domain models
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

        //convert domain models into persisted data
        let payload = try JSONEncoder().encode(
            forecast
        )

        if let existing = try fetchEntity(
            for: key
        ) {

            //update existing cached forecast
            existing.payload = payload
            existing.fetchedAt = fetchedAt

        } else {
            //create persistence entity inside the data layer
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
