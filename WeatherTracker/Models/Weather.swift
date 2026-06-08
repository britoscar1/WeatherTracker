//
//  Weather.swift
//  WeatherTracker
//
//  Created by Oscar Artemio Brito Ortiz on 06/06/26.
//

import Foundation

struct GeoCodingResult: Codable{
    let name: String
    let latitude: Double
    let longitude: Double
}

struct WeatherModel: Codable {
    let results: [GeoCodingResult]?
}

struct ForecastReponse: Codable {
    let current_weather: CurrentWeather
}

struct CurrentWeather: Codable {
    let time: String
    let temperature: Double
    let windspeed: Double
    let weathercode: Int
    
    static func description(from weathercode: Int) -> String{
        switch weathercode {
        case 0:
            return "Clear sky"
        case 1,2,3:
            return "Partly cloudy"
        case 45, 48:
            return "Foggy"
        case 51, 53, 55:
            return "Drizzle"
        case 61, 63, 65:
            return "Rain"
        case 71,73,75:
            return "Snow"
        case 80, 81, 82:
            return "Rain showers"
        case 95:
            return "Thunderstorm"
        case 96, 99:
            return "Thunderstorm with hail"
        default:
            return "Unknown"
        }
    }
    
}



