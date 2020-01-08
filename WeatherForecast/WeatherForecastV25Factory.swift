//
//  WeatherForecastV25Factory.swift
//  WeatherForecast
//
//  Created by Howie C on 1/6/20.
//  Copyright © 2020 Howie C. All rights reserved.
//

import Foundation

// immediate object to perform parsing
private struct CodableWeatherForecasts: Decodable {
    
    var weatherForecastArray: [Dictionary<String, Any>]
    
    enum Level00Keys: CodingKey {
        case list
    }
    
    enum Level01Keys: CodingKey {
        case temp
    }
    
    enum Level02Keys: String, CodingKey {
        case dayTemperature = "day"
        case minimumTemperature = "min"
        case maximumTemperature = "max"
    }
    
    init(from decoder: Decoder) throws {
        let level00Container = try decoder.container(keyedBy: Level00Keys.self)
        var level01Container = try level00Container.nestedUnkeyedContainer(forKey: .list)
        weatherForecastArray = []
        while !level01Container.isAtEnd {
            var weatherForecastDictionary: [String : Any] = [:]
            let level02Container = try level01Container.nestedContainer(keyedBy: Level01Keys.self)
            let level03Container = try level02Container.nestedContainer(keyedBy: Level02Keys.self, forKey: .temp)
            weatherForecastDictionary["dayTemperature"] = try level03Container.decode(Double.self, forKey: .dayTemperature)
            weatherForecastDictionary["minimumTemperature"] = try level03Container.decode(Double.self, forKey: .minimumTemperature)
            weatherForecastDictionary["maximumTemperature"] = try level03Container.decode(Double.self, forKey: .maximumTemperature)
            weatherForecastArray.append(weatherForecastDictionary)
        }
    }
    
}

// alternatively can use JSONSerialization, or other ways of parsing
class WeatherForecastV25Factory: WeatherForecastFactory {
    
    func makeWeatherForecasts(data: Data) throws -> Array<Dictionary<String, Any>> {
        let makeWeatherForecasts = makeWeatherForecastsClosure()
        return try makeWeatherForecasts(data)
    }
    
    func makeWeatherForecastsClosure() -> (Data) throws -> Array<Dictionary<String, Any>> {
        return {
            let codableWeatherForecasts = try JSONDecoder().decode(CodableWeatherForecasts.self, from: $0)
            // Thread.sleep(forTimeInterval: 5) // test: make sure UI is responsive
            return codableWeatherForecasts.weatherForecastArray
        }
    }
    
}
