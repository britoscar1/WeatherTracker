import Foundation
import Combine
import SwiftUI

enum WeatherLoadState {
    case loading
    case loaded(CurrentWeather)
    case failed(String)
}

@MainActor
class WeatherViewModel: ObservableObject {

    // Per-location weather states (keyed by SavedLocation.id)
    @Published var weatherStates: [UUID: WeatherLoadState] = [:]

    // State for the "add location" search flow
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle

    enum SearchState {
        case idle
        case searching
        case found(GeoCodingResult)
        case error(String)
    }

    private let api = APIService()
    private var fetchTasks: [UUID: Task<Void, Never>] = [:]
    private var searchTask: Task<Void, Never>?

    // MARK: - Weather fetching

    func fetchWeather(for location: SavedLocation) {
        // Cancel any in-flight request for this location before starting a new one
        fetchTasks[location.id]?.cancel()
        weatherStates[location.id] = .loading

        // Capture value types only to avoid Sendable issues with @Model class
        let lat = location.latitude
        let lon = location.longitude
        let id  = location.id

        fetchTasks[id] = Task {
            do {
                let weather = try await api.fetchWeather(latitude: lat, longitude: lon)
                guard !Task.isCancelled else { return }
                weatherStates[id] = .loaded(weather)
            } catch {
                guard !Task.isCancelled else { return }
                weatherStates[id] = .failed(message(for: error))
            }
        }
    }

    func fetchAll(locations: [SavedLocation]) {
        for location in locations {
            fetchWeather(for: location)
        }
    }

    func cancelFetch(for locationID: UUID) {
        fetchTasks[locationID]?.cancel()
        fetchTasks[locationID] = nil
        weatherStates.removeValue(forKey: locationID)
    }

    // MARK: - City search (used by AddLocationView)

    func searchCity() {
        searchTask?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchState = .error("Please enter a city name")
            return
        }
        searchState = .searching

        searchTask = Task {
            do {
                let result = try await api.searchLocation(city: trimmed)
                guard !Task.isCancelled else { return }
                searchState = .found(result)
            } catch {
                guard !Task.isCancelled else { return }
                searchState = .error(message(for: error))
            }
        }
    }

    func resetSearch() {
        searchTask?.cancel()
        searchText = ""
        searchState = .idle
    }

    // MARK: - Δ and % math

    func delta(current: Double, baseline: Double) -> Double {
        current - baseline
    }

    /// Returns nil when baseline is 0 to avoid divide-by-zero
    func percentChange(current: Double, baseline: Double) -> Double? {
        guard baseline != 0 else { return nil }
        return ((current - baseline) / abs(baseline)) * 100
    }

    // MARK: - Helpers

    private func message(for error: Error) -> String {
        guard let networkError = error as? NetworkError else {
            return "Something went wrong"
        }
        switch networkError {
        case .invalidURL:               return "Invalid URL"
        case .invalidResponse:          return "Invalid response"
        case .noResults:                return "City not found"
        case .badStatusCode(let code):  return "Server error (\(code))"
        }
    }
}
