//
//  CityDTO.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

struct CitySearchResponseDTO: Decodable, Sendable {
    let results: [CityDTO]?
}

struct CityDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
    let timezone: String?
}
