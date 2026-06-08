//
//  APIService.swift
//  WeatherTracker
//
//  Created by Oscar Artemio Brito Ortiz on 06/06/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case badStatusCode (statusCode: Int)
    case noResults
}

class APIService {
    
    // user function
    func fetchCurrentWeather(city: String) async throws -> (cityName: String, weather: CurrentWeather) {

        let location: GeoCodingResult = try await fetchCordinates(forCity: city)
        let currentWeather: CurrentWeather = try await fetchWeather(latitude: location.latitude, longitude: location.longitude)

        return (location.name, currentWeather)
    }
    
    
    
    // MARK: MAIN GET REQUEST (URLSession) CORE FUNCTION
    
     private func get(url: URL) async throws -> Data {
        let session: URLSession = URLSession.shared
        
        let result: (Data, URLResponse) = try await session.data(from: url)
        
        let data: Data = result.0 // Data -> Content -> JSON
        let response: URLResponse = result.1 // URLResponse -> Information about the request (statuscode, headers, tokens, etc
        
        if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse {
            let statusCode: Int = httpResponse.statusCode
            
            if statusCode < 200 || statusCode > 299 {
                throw NetworkError.badStatusCode(statusCode: statusCode)
            }
            
            return data
        }
        
        throw NetworkError.invalidResponse
    }
    
    // API 1: User sends a CityName and API returns the JSOn to parse it into a model
    
    private func fetchCordinates(forCity city: String) async throws -> GeoCodingResult {
        
        // BASE URL: https://geocoding-api.open-meteo.com/v1/search
        
        var urlComponents: URLComponents? = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        
        if urlComponents == nil{
            throw NetworkError.invalidURL
        }
        urlComponents?.queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        
        let url: URL? = urlComponents?.url
        if url == nil {
            throw NetworkError.invalidURL
        }
        
        let data: Data = try await get(url: url!)
        let decoder: JSONDecoder = JSONDecoder()
        let response: WeatherModel = try decoder.decode(WeatherModel.self, from: data)
        
        if let result: [GeoCodingResult] = response.results {
            if let firstResult: GeoCodingResult = result.first {
                return firstResult
            }
        }
        throw NetworkError.noResults
        
    }
    
    private func fetchWeather(latitude: Double, longitude: Double) async throws -> CurrentWeather {
        
        // BASE URL: https://api.open-meteo.com/v1/forecast
        
        var urlComponents: URLComponents? = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        
        if urlComponents == nil{
            throw NetworkError.invalidURL
        }
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        
        let url: URL? = urlComponents?.url
        if url == nil {
            throw NetworkError.invalidURL
        }
        
        let data: Data = try await get(url: url!)
        let decoder: JSONDecoder = JSONDecoder()
        let response: ForecastReponse = try decoder.decode(ForecastReponse.self, from: data)
        
        return response.current_weather
      
        
    }
}


