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
                }
                .listStyle(.plain)

            case .empty:
                Text("No Recommendations")

            case .error(let message):
                Text("Unable to Load")
            }
        }
        .navigationTitle(viewModel.cityName)
        .task {
            await viewModel.load()
        }
    }
}
