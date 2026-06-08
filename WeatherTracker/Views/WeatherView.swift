//
//  WeatherView.swift
//  WeatherTracker
//
//  Created by Oscar Artemio Brito Ortiz on 06/06/26.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("Weather")
                    .font(.largeTitle)
                    .bold()

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search city...", text: $viewModel.searchText)
                        .onSubmit {
                            Task { await viewModel.searchCity() }
                        }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                .padding(.horizontal)

  
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }


                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                }

                if !viewModel.cityName.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 16) {

                        Text(viewModel.cityName)
                            .font(.title)
                            .bold()

                        Text(viewModel.temperature)
                            .font(.system(size: 52, weight: .thin))

                        Text(viewModel.timeText)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Divider()

                        HStack(spacing: 32) {
                            WeatherStatView(icon: "wind", label: "Wind", value: viewModel.windText)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 32)
        }
    }
}

struct WeatherStatView: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.subheadline)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
