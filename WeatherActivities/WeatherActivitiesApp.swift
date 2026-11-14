//
//  WeatherActivitiesApp.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import SwiftUI

@main
struct WeatherActivitiesApp: App {

    @State private var citySearchViewModel =
        DependencyContainer().makeCitySearchViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CitySearchView(
                    viewModel: citySearchViewModel
                )
            }
        }
    }
}
