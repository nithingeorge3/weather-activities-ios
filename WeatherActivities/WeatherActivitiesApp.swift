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

    init() {
        let container = DependencyContainer()

        self.container = container

        _citySearchViewModel = State(
            initialValue: container.makeCitySearchViewModel()
        )
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {

                CitySearchView(
                    viewModel: citySearchViewModel
                )
                .navigationDestination(for: CityRowViewData.self) { city in

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
