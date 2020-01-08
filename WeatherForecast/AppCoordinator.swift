//
//  AppCoordinator.swift
//  WeatherForecast
//
//  Created by Howie C on 12/17/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class AppCoordinator: WindowCoordinator {
    
    override func start() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let weatherForecastCoordinator = WeatherForecastCoordinator(navigationController: navigationController)
        childCoordinators.append(weatherForecastCoordinator)
        weatherForecastCoordinator.start()
        window.makeKeyAndVisible()
    }
    
}
