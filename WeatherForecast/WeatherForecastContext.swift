//
//  WeatherForecastContext.swift
//  WeatherForecast
//
//  Created by Howie C on 1/5/20.
//  Copyright © 2020 Howie C. All rights reserved.
//

import Foundation

// dependency inversion
protocol WeatherForecastGateway {
    // use plain objects between layers
    func getWeatherForecast(forCity city: String, withCompletionHandler completionHandler: @escaping (Array<Dictionary<String, Any>>, Error?) -> Void)
    
    func cancel()
    
}

private enum WeatherForecastContextError: Error {
    case invalidNewsFeedData
}

class WeatherForecastContext {
    var weatherForecastGateway: WeatherForecastGateway
    
    init(weatherForecastGateway: WeatherForecastGateway) {
        self.weatherForecastGateway = weatherForecastGateway
    }
    
    func fetchWeatherForecast(forCity city: String, withCompletionHandler completionHandler: @escaping ([WeatherForecast], Error?) -> Void) {
        // even by using an intermediate local variable referencing a function, closures would still capture 'self'
        // by making a closure, the other closure does not need to capture 'self'
        let makeWeatherForecast = makeWeatherForecastsClosure()
        weatherForecastGateway.getWeatherForecast(forCity: city) { (weatherForecastArray, error) in
            if error == nil {
                DispatchQueue.global(qos: .userInitiated).async {
                    //especially ensures that the parsing is not in main queue
                    do {
                        // completionHandler could still get executed when this closure executed even 'self' is released
                        completionHandler(try makeWeatherForecast(weatherForecastArray), nil)
                    } catch {
                        completionHandler([], error)
                    }
                }
            } else {
                completionHandler([], error)
            }
        }
    }
    
    private func makeWeatherForecastsClosure() -> (Array<Dictionary<String, Any>>) throws -> [WeatherForecast] {
        return { weatherForecastArray in
            return try weatherForecastArray.map({ (weatherForecastDictionary) -> WeatherForecast in
                if let dayTemperature = weatherForecastDictionary["dayTemperature"] as? Double, let _ = weatherForecastDictionary["minimumTemperature"] as? Double, let _ = weatherForecastDictionary["maximumTemperature"] as? Double {
                    return WeatherForecast(temperature: dayTemperature)
                } else {
                    throw WeatherForecastContextError.invalidNewsFeedData
                }
            })
        }
    }
    
}
