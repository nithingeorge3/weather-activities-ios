//
//  CityDomain.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

struct CityDomain: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
    let timeZoneID: String?
}

//MARK: - DTO to Domain

extension CityDTO {

    func toDomain() -> CityDomain {
        CityDomain(
            id: id,
            name: name,
            country: country ?? "",
            region: admin1,
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timezone
        )
    }
}
