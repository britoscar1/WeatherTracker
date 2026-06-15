import Foundation

struct GeoCodingResult: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct GeocodingResponse: Codable {
    let results: [GeoCodingResult]?
}

struct ForecastResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let time: String
    let temperature: Double
    let windSpeed: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windSpeed = "wind_speed_10m"
        case weatherCode = "weather_code"
    }

    static func label(for code: Int) -> String {
        switch code {
        case 0:          return "Clear sky"
        case 1, 2, 3:   return "Partly cloudy"
        case 45, 48:     return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 80, 81, 82: return "Rain showers"
        case 95:         return "Thunderstorm"
        case 96, 99:     return "Thunderstorm with hail"
        default:         return "Unknown"
        }
    }
}
