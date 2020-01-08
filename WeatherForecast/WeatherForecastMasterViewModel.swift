//
//  WeatherForecastMasterViewModel.swift
//  WeatherForecast
//
//  Created by Howie C on 12/17/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

class WeatherForecastMasterViewModel: WeatherForecastViewModel {
    
    private let weatherForecastContext: WeatherForecastContext
    private var city = ""
    private var weatherForecastArray: [WeatherForecast] = []
    
    init(weatherForecastContext: WeatherForecastContext) {
        self.weatherForecastContext = weatherForecastContext
    }
    
    var title: String {
        return city + "\(city != "" ? " " : "")" + NSLocalizedString("WeatherForecastMasterViewController.title", value: "Weather Forecast", comment: "")
    }
    
    var weatherForecastCount: Int {
        return weatherForecastArray.count
    }
    
    func weatherForecast(atIndex index: Int, inCelsius: Bool) -> String {
        let weatherForecast = weatherForecastArray[index]
        let temperature = weatherForecast.temperature
        return "\(inCelsius ? temperature : temperature * 1.8 + 32)°\(inCelsius ? "C" : "F")"
    }
    
    func reloadWeatherForecast(forCity city: String, withCompletionHandler completionHandler: @escaping (Error?) -> Void) {
        weatherForecastContext.fetchWeatherForecast(forCity: city) { [weak self] (weatherForecastArray, error) in
            if let self = self {
                if error == nil {
                    self.city = city
                    self.weatherForecastArray = weatherForecastArray
                } else {
                    self.city = ""
                    self.weatherForecastArray = []
                }
            }
            completionHandler(error)
        }
    }
    
}
