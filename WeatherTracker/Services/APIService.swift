import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case badStatusCode(statusCode: Int)
    case noResults
}

struct APIService {

    func searchLocation(city: String) async throws -> GeoCodingResult {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        guard components != nil else { throw NetworkError.invalidURL }
        components?.queryItems = [
            URLQueryItem(name: "name",     value: city),
            URLQueryItem(name: "count",    value: "1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format",   value: "json")
        ]
        guard let url = components?.url else { throw NetworkError.invalidURL }

        let data = try await get(url: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        guard let first = response.results?.first else { throw NetworkError.noResults }
        return first
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> CurrentWeather {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        guard components != nil else { throw NetworkError.invalidURL }
        components?.queryItems = [
            URLQueryItem(name: "latitude",  value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current",   value: "temperature_2m,wind_speed_10m,weather_code"),
            URLQueryItem(name: "timezone",  value: "auto")
        ]
        guard let url = components?.url else { throw NetworkError.invalidURL }

        let data = try await get(url: url)
        return try JSONDecoder().decode(ForecastResponse.self, from: data).current
    }

    private func get(url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.badStatusCode(statusCode: http.statusCode)
        }
        return data
    }
}
