//
//  WeatherForecastMasterViewController.swift
//  WeatherForecast
//
//  Created by Howie C on 12/17/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

protocol WeatherForecastViewModel {
    
    var title: String { get }
    var weatherForecastCount: Int { get }
    
    func weatherForecast(atIndex index: Int, inCelsius: Bool) -> String
    
    func reloadWeatherForecast(forCity city: String, withCompletionHandler completionHandler: @escaping (Error?) -> Void)
}

class WeatherForecastMasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    var weatherForecastViewModel: WeatherForecastViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = weatherForecastViewModel.title
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Celsius", style: .plain, target: self, action: #selector(toggleTemperatureUnit))
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass(), forCellReuseIdentifier: tableViewCellReuseIdentifier())
        tableView.register(headerClass(), forHeaderFooterViewReuseIdentifier: tableViewHeaderViewReuseIdentifier())
        tableView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(tableView)
        searchBar = UISearchBar()
        searchBar.placeholder = "Search City Weather Forecast"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 0)
        searchBar.sizeToFit()
        searchBar.delegate = self
        weatherForecastViewModel.reloadWeatherForecast(forCity: "London") { [weak self] (error) in
            DispatchQueue.main.async {
                if let self = self {
                    if error == nil {
                        self.title = self.weatherForecastViewModel.title
                        self.tableView.reloadData()
                    } else {
                        let alertController = UIAlertController(title: "Alert", message: String(describing: error), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: -
    @objc private func toggleTemperatureUnit() {
        if navigationItem.rightBarButtonItem?.title == "Celsius" {
            navigationItem.rightBarButtonItem?.title = "Fahrenheit"
        } else {
            navigationItem.rightBarButtonItem?.title = "Celsius"
        }
        tableView.reloadData()
    }
    
    private func cellClass() -> AnyClass {
        return UITableViewCell.self
    }
    
    private func tableViewCellReuseIdentifier() -> String {
        return String(describing: cellClass())
    }
    
    private func headerClass() -> AnyClass {
        return UITableViewHeaderFooterView.self
    }
    
    private func tableViewHeaderViewReuseIdentifier() -> String {
        return String(describing: headerClass())
    }
    
    // MARK: - UITableViewDataSource Protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForecastViewModel.weatherForecastCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellReuseIdentifier(), for: indexPath)
        cell.textLabel?.text = weatherForecastViewModel.weatherForecast(atIndex: indexPath.row, inCelsius: navigationItem.rightBarButtonItem?.title == "Celsius")
        return cell
    }
    
    // MARK: - UITableViewDelegate Protocol
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableViewHeaderViewReuseIdentifier())
            // much efficient to test before invoking addSubview:
            // much faster than if !headerView?.subviews.contains(searchBar); tested
            if let headerView = headerView, !searchBar.isDescendant(of: headerView) {
                headerView.contentView.addSubview(searchBar)
                print(searchBar.frame)
            }
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return searchBar.frame.height
        default:
            return 0
        }
    }
    
    // MARK: - UIScrollViewDelegate Protocol
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate Protocol
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            weatherForecastViewModel.reloadWeatherForecast(forCity: text) { [weak self] (error) in
                DispatchQueue.main.async {
                    if let self = self {
                        if error == nil {
                            self.title = self.weatherForecastViewModel.title
                            self.tableView.reloadData()
                            self.searchBar.resignFirstResponder()
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        } else {
                            let alertController = UIAlertController(title: "Alert", message: String(describing: error), preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
  
}
