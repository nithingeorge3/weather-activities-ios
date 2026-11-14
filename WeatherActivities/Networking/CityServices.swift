//
//  CityServices.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

protocol CityServiceProtocol: Sendable {
    func searchCities(query: String) async throws -> [CityDTO]
}

enum CityServiceError: Error {
    case invalidURL
}

struct CityService: CityServiceProtocol {

    private let httpClient: any HTTPClientProtocol

    init(httpClient: any HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    func searchCities(query: String) async throws -> [CityDTO] {

        var components = URLComponents()
        components.scheme = "https"
        components.host = "geocoding-api.open-meteo.com"
        components.path = "/v1/search"

        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en")
        ]

        guard let url = components.url else {
            throw CityServiceError.invalidURL
        }

        let data = try await httpClient.get(url: url)

        let response = try JSONDecoder().decode(
            CitySearchResponseDTO.self,
            from: data
        )

        return response.results ?? []
    }
}
