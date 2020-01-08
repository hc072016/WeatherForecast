//
//  WeatherForecastCoordinator.swift
//  WeatherForecast
//
//  Created by Howie C on 12/17/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class WeatherForecastCoordinator: NavigationCoordinator {
    
    override func start() {
        let weatherForecastMasterViewController = WeatherForecastMasterViewController()
        weatherForecastMasterViewController.weatherForecastViewModel = WeatherForecastMasterViewModel(weatherForecastContext: WeatherForecastContext(weatherForecastGateway: WeatherForecastNetwork(weatherForecastFactory: WeatherForecastV25Factory())))
        navigationController.pushViewController(weatherForecastMasterViewController, animated: false)
    }
    
}
