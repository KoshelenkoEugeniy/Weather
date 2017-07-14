//
//  SelectedCitiesTableViewCell.swift
//  Weather
//
//  Created by Евгений on 07.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit

// Table view cell only for selected cities 

class SelectedCitiesTableViewCell: UITableViewCell {

    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var cityTemperature: UILabel!
    
    var cityForecast: weatherForecast? { didSet { updateUI() } }
    
    func updateUI() {
        cityName?.text = cityForecast?.cityName!
        cityTemperature?.text = String(describing: cityForecast?.main.temp!)
    }
    
}
