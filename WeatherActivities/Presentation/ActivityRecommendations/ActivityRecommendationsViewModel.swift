//
//  ActivityRecommendationsViewModel.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation
import Observation

enum ActivityRecommendationsState {
    case idle
    case loading
    case results([ActivityRecommendationRowViewData])
    case empty
    case error(String)
}

@MainActor
@Observable
final class ActivityRecommendationsViewModel {

    private(set) var state: ActivityRecommendationsState = .idle

    let cityName: String

    private let latitude: Double
    private let longitude: Double
    private let timeZoneID: String?

    private let useCase: any GetActivityRecommendationsUseCaseProtocol

    init(
        cityName: String,
        latitude: Double,
        longitude: Double,
        timeZoneID: String?,
        useCase: any GetActivityRecommendationsUseCaseProtocol
    ) {
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneID = timeZoneID
        self.useCase = useCase
    }

    deinit {
        print("deinit ActivityRecommendationsViewModel")
    }
    
    func load() async {

        state = .loading

        do {
            let recommendations = try await useCase.execute(
                latitude: latitude,
                longitude: longitude,
                timeZoneID: timeZoneID
            )

            try Task.checkCancellation()

            let results = recommendations.map {
                $0.toPresentation()
            }

            state = results.isEmpty
                ? .empty
                : .results(results)

        } catch is CancellationError {
            return

        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }
}
