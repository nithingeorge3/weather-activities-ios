//
//  CitySearchView.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import SwiftUI

struct CitySearchView: View {

    @Bindable var viewModel: CitySearchViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            searchSection

            stateContent
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .navigationTitle("Weather Activities")
    }

    // MARK: - Search

    private var searchSection: some View {

        VStack(spacing: 12) {

            TextField(
                "Search for a city",
                text: $viewModel.query
            )
            .textFieldStyle(.roundedBorder)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit {
                performSearch()
            }

            Button {
                performSearch()
            } label: {
                Text("Search")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
            .controlSize(.large)
            .disabled(!viewModel.canSearch)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - State

    @ViewBuilder
    private var stateContent: some View {

        switch viewModel.state {

        case .idle:
            ContentUnavailableView(
                "Find a City",
                systemImage: "magnifyingglass",
                description: Text(
                    "Search for a city to discover suitable activities."
                )
            )

        case .loading:
            ProgressView("Searching...")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

        case .results(let cities):
            List(cities) { city in

                VStack(alignment: .leading, spacing: 4) {

                    Text(city.title)
                        .font(.headline)

                    Text(city.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)

        case .empty:
            ContentUnavailableView(
                "No Cities Found",
                systemImage: "magnifyingglass",
                description: Text(
                    "Try searching for another city."
                )
            )

        case .error(let message):
            ContentUnavailableView(
                "Search Failed",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }

    // MARK: - Actions

    private func performSearch() {
        Task {
            await viewModel.search()
        }
    }
}

#if DEBUG

private struct PreviewSearchCitiesUseCase: SearchCitiesUseCaseProtocol {

    func execute(query: String) async throws -> [CityDomain] {

        [
            CityDomain(
                id: 2643743,
                name: "London",
                country: "United Kingdom",
                region: "England",
                latitude: 51.5085,
                longitude: -0.1257,
                timeZoneID: "Europe/London"
            )
        ]
    }
}

#Preview("City Search") {

    NavigationStack {
        CitySearchView(
            viewModel: CitySearchViewModel(
                searchCitiesUseCase: PreviewSearchCitiesUseCase()
            )
        )
    }
}

#endif
