//
//  CityDTO.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

struct CityDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
    let timezone: String?
}

////MARK: - mapper DTO - > Domain
//extension CityDTO {
//    func toDomain() -> City {
//        City(
//            id: id,
//            name: name,
//            country: country ?? "",
//            region: admin1,
//            latitude: latitude,
//            longitude: longitude,
//            timeZoneID: timezone
//        )
//    }
//}
