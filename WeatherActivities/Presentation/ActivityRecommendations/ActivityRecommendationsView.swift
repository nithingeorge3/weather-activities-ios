//
//  ActivityRecommendationsView.swift
//  WeatherActivities
//
//  Created by Nitin George on 13/11/2026.
//

import SwiftUI

struct ActivityRecommendationsView: View {

    @State private var viewModel: ActivityRecommendationsViewModel

    init(viewModel: ActivityRecommendationsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {

            case .idle, .loading:
                ProgressView("Loading recommendations...")

            case .results(let activities):
                List(activities) { activity in

                    VStack(alignment: .leading, spacing: 8) {

                        HStack {
                            Text(activity.title)
                                .font(.headline)

                            Spacer()

                            Text("\(activity.score)/100")
                                .font(.headline)
                        }

                        Text(activity.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Best day: \(activity.bestDay)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(
                        "activityRecommendations.row.\(activity.title)"
                    )
                }
                .listStyle(.plain)
                .accessibilityIdentifier("activityRecommendations.list")
                .refreshable {
                    await viewModel.refresh()
                }

            case .empty:

                Text("No Recommendations")

            case .error(let message):

                ContentUnavailableView(
                    "Unable to Load",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
        .navigationTitle(viewModel.cityName)
        .alert(
            "Unable to Refresh",
            isPresented: $viewModel.showRefreshError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Showing previous recommendations. Please try again.")
        }
        .task {
            await viewModel.load()
        }
    }
}
