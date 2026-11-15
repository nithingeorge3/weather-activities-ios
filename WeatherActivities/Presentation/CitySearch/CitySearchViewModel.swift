//
//  CitySearchViewModel.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import Foundation
import Observation

enum CitySearchState {
    case idle
    case loading
    case results([CityRowViewData])
    case empty
    case error(String)
}

@MainActor
@Observable
final class CitySearchViewModel {

    var query = ""
    
    var canSearch: Bool {
        query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .count >= 2
    }

    private(set) var state: CitySearchState = .idle

    private let searchCitiesUseCase: any SearchCitiesUseCaseProtocol

    init(
        searchCitiesUseCase: any SearchCitiesUseCaseProtocol
    ) {
        self.searchCitiesUseCase = searchCitiesUseCase
    }
    
    // Workaround for Swift/XCTest deallocation crash on iOS 26.2.
    // See https://github.com/swiftlang/swift/issues/87316
    nonisolated deinit {}
}

//MARK: - Services
extension CitySearchViewModel {
    func search() async {

        guard canSearch else { return }

        let searchQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        state = .loading

        do {
            let cities = try await searchCitiesUseCase.execute(
                query: searchQuery
            )

            try Task.checkCancellation()

            let results = cities.map {
                $0.toPresentation()
            }

            state = results.isEmpty
                ? .empty
                : .results(results)

        } catch is CancellationError {
            return

        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
