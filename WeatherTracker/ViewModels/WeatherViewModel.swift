//
//  WeatherViewModel.swift
//  WeatherTracker
//
//  Created by Oscar Artemio Brito Ortiz on 06/06/26.
//

import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    @Published var cityName: String = ""
    @Published var temperature: String = ""
    @Published var windText: String = ""
    @Published var timeText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage:String = ""

    let api: APIService = APIService()
    
    func searchCity() async {
        self.errorMessage = ""
        self.isLoading = true
        
        let trimmedText: String = self.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            errorMessage = "Please enter a city name"
            self.isLoading = false
            return
        }
        
        do{
            let result = try await api.fetchCurrentWeather(city: trimmedText)
            self.cityName = result.cityName
            self.temperature = "Temp: \(result.weather.temperature)"
            self.windText = "Wind: \(result.weather.windspeed)"
            self.timeText = "Time: \(result.weather.time)"
            self.isLoading = false
        } catch let error as NetworkError{
            switch error{
                case .invalidURL:
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            case .noResults:
                self.errorMessage = "No results found"
                self.isLoading = false
            case .badStatusCode(statusCode: let statusCode):
                self.errorMessage = "Bad status code: \(statusCode)"
                self.isLoading = false
            case .invalidResponse:
                self.errorMessage = "Invalid response"
                self.isLoading = false
            }
            
        }catch{
            self.errorMessage = "Something went wrong"
            self.isLoading = false
        }
    }

}

