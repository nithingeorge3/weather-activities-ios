//
//  DependencyContainer.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

@MainActor
struct DependencyContainer {

    func makeCitySearchViewModel() -> CitySearchViewModel {

        let service = CityService()

        let repository = CityRepository(
            service: service
        )

        let useCase = SearchCitiesUseCase(
            repository: repository
        )

        return CitySearchViewModel(
            searchCitiesUseCase: useCase
        )
    }
}
