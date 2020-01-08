//
//  WeatherForecastNetwork.swift
//  WeatherForecast
//
//  Created by Howie C on 1/5/20.
//  Copyright © 2020 Howie C. All rights reserved.
//

import Foundation

// dependency inversion
protocol WeatherForecastFactory {
    
    func makeWeatherForecasts(data: Data) throws -> Array<Dictionary<String, Any>>
    
    func makeWeatherForecastsClosure() -> (Data) throws -> Array<Dictionary<String, Any>>
}

private enum WeatherForecastNetworkError: Error {
    case notFound
    case invalidURL
    case nilData
    case invalidHTTPResponse
}

class WeatherForecastNetwork: WeatherForecastGateway {
    
    // five days' weather forecasts
    let weatherForecastURLString = "https://api.openweathermap.org/data/2.5/forecast/daily?units=metric&cnt=5"
    let appid = ""
    let weatherForecastFactory: WeatherForecastFactory
    
    init(weatherForecastFactory: WeatherForecastFactory) {
        self.weatherForecastFactory = weatherForecastFactory
    }
    func getWeatherForecast(forCity city: String, withCompletionHandler completionHandler: @escaping (Array<Dictionary<String, Any>>, Error?) -> Void) {
        if let url = URL(string: weatherForecastURLString + "&q=\(city)" + "&appid=\(appid)") {
            let makeWeatherForecasts = weatherForecastFactory.makeWeatherForecastsClosure()
            let urlSessionDataTask = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
                // not in main thread here!
                //if !Thread.isMainThread {
                //    print("not in main thread")
                //}
                if error != nil {
                    completionHandler([], error)
                } else {
                    if let httpURLResponse = urlResponse as? HTTPURLResponse {
                        if httpURLResponse.statusCode == 200 {
                            if let data = data {
                                DispatchQueue.global(qos: .userInitiated).async {
                                    //especially ensures that the parsing is not in main queue
                                    do {
                                        completionHandler(try makeWeatherForecasts(data), nil)
                                    } catch {
                                        completionHandler([], WeatherForecastNetworkError.invalidHTTPResponse)
                                    }
                                }
                            } else {
                                completionHandler([], WeatherForecastNetworkError.nilData)
                            }
                        } else {
                            completionHandler([], WeatherForecastNetworkError.notFound)
                        }
                    } else {
                        completionHandler([], WeatherForecastNetworkError.invalidHTTPResponse)
                    }
                }
            }
            urlSessionDataTask.resume()
        } else {
            completionHandler([], WeatherForecastNetworkError.invalidURL)
        }
    }
    
    func cancel() {
        // to do
    }
    
    
}
