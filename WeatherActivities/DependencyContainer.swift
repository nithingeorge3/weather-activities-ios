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
