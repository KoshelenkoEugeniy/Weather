//
//  CitiesListTableViewCell.swift
//  Weather
//
//  Created by Евгений on 07.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit

class CitiesListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameOfCity: UILabel!
    
    @IBOutlet weak var nameOfCountry: UILabel!
    
    var city: City? { didSet { updateUI() } }
    
    func updateUI() {
        nameOfCity?.text = city?.name
        nameOfCountry?.text = city?.country
    }
    
}
