//
//  WeatherActivitiesApp.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import SwiftUI

@main
struct WeatherActivitiesApp: App {

    private let container: DependencyContainer

    @State private var citySearchViewModel: CitySearchViewModel

    // MARK: - Initialization
    init() {

        // Initialize caching when available.
        // The app continues without caching if initialization fails.
        let forecastCache = WeatherPersistence.makeForecastCache()

        let container = DependencyContainer(
            forecastCache: forecastCache
        )

        self.container = container

        _citySearchViewModel = State(
            initialValue: container.makeCitySearchViewModel()
        )
    }

    // MARK: - App Scene
    var body: some Scene {

        WindowGroup {

            NavigationStack {

                CitySearchView(
                    viewModel: citySearchViewModel
                )
                .navigationDestination(
                    for: CityRowViewData.self
                ) { city in

                    ActivityRecommendationsView(
                        viewModel: container.makeActivityRecommendationsViewModel(
                            city: city
                        )
                    )
                }
            }
        }
    }
}
