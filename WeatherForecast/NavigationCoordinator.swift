//
//  NavigationCoordinator.swift
//  WeatherForecast
//
//  Created by Howie C on 12/17/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class NavigationCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
}
