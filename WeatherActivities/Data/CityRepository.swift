//
//  CityRepository.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

protocol CityRepositoryProtocol: Sendable {
    func searchCities(query: String) async throws -> [CityDomain]
}

struct CityRepository: CityRepositoryProtocol {

    private let service: any CityServiceProtocol

    init(service: any CityServiceProtocol) {
        self.service = service
    }

    func searchCities(query: String) async throws -> [CityDomain] {
        let cityDTOs = try await service.searchCities(query: query)

        return cityDTOs.map { $0.toDomain() }
    }
}
