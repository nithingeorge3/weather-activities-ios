//
//  CityServices.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

protocol CityServiceProtocol: Sendable {
    func searchCities(query: String) async throws -> [CityDTO]
}

struct CityService: CityServiceProtocol {

    func searchCities(query: String) async throws -> [CityDTO] {
        // TODO: Integrate geocoding API.
        return []
    }
}
