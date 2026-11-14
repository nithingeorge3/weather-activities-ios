//
//  SearchCitiesUseCase.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

protocol SearchCitiesUseCaseProtocol: Sendable {
    func execute(query: String) async throws -> [CityDomain]
}

enum SearchCitiesError: Error {
    case queryTooShort
}

struct SearchCitiesUseCase: SearchCitiesUseCaseProtocol {

    private let repository: any CityRepositoryProtocol

    init(repository: any CityRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [CityDomain] {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard trimmedQuery.count >= 2 else {
            throw SearchCitiesError.queryTooShort
        }

        return try await repository.searchCities(
            query: trimmedQuery
        )
    }
}
