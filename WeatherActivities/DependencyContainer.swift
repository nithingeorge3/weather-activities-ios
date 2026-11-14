//
//  DependencyContainer.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation

@MainActor
struct DependencyContainer {

    func makeCitySearchViewModel() -> CitySearchViewModel {

        let httpClient = URLSessionHTTPClient()

        let cityService = CityService(
            httpClient: httpClient
        )

        let cityRepository = CityRepository(
            service: cityService
        )

        let searchCitiesUseCase = SearchCitiesUseCase(
            repository: cityRepository
        )

        return CitySearchViewModel(
            searchCitiesUseCase: searchCitiesUseCase
        )
    }
}

//MARK: activity recommendations

extension DependencyContainer {
    func makeActivityRecommendationsViewModel(
        city: CityRowViewData
    ) -> ActivityRecommendationsViewModel {

        let httpClient = URLSessionHTTPClient()

        let service = ForecastService(
            httpClient: httpClient
        )

        let repository = WeatherRepository(
            service: service
        )

        let useCase = GetActivityRecommendationsUseCase(
            repository: repository
        )

        return ActivityRecommendationsViewModel(
            cityName: city.title,
            latitude: city.latitude,
            longitude: city.longitude,
            timeZoneID: city.timeZoneID,
            useCase: useCase
        )
    }
}
