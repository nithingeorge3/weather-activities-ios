//
//  CityRowViewData.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

struct CityRowViewData: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
    let timeZoneID: String?
}

extension CityDomain {

    func toPresentation() -> CityRowViewData {
        let subtitle = [
            region,
            country
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")

        return CityRowViewData(
            id: id,
            title: name,
            subtitle: subtitle,
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timeZoneID
        )
    }
}
