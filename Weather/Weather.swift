//
//  Weather.swift
//  Weather
//
//  Created by Евгений on 09.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import Foundation
import UIKit

struct Weather {
    var id: Int?
    var description: String?
    var icon: UIImageView?
    
    init(){
        self.id = nil
        self.description = nil
        self.icon = nil
    }
    
    init(id: Int?, description: String?, icon: UIImageView?){
        self.id = id
        self.description = description
        self.icon = icon
    }
}

struct Main {
    var temp: Float?
    var pressure: Float?
    var humidity: Float?
    
    init(){
        self.temp = nil
        self.pressure = nil
        self.humidity = nil
    }
    init(temp: Float?, pressure: Float?, humidity: Float?){
        self.temp = temp
        self.pressure = pressure
        self.humidity = humidity
    }
}

struct weatherForecast {
    var coord: Coordinates
    var weather: Weather
    var main: Main
    var windSpeed: Float?
    var clouds: Float?
    var cityId: Int?
    var cityName: String?
    
    init(){
        self.coord = Coordinates()
        self.weather = Weather()
        self.main = Main()
        self.windSpeed = nil
        self.clouds = nil
        self.cityId = nil
        self.cityName = nil
    }
    
    init(coord: Coordinates, weather: Weather, main: Main, windSpeed: Float?, clouds: Float?, cityId: Int?, cityName: String?){
        self.coord = coord
        self.weather = weather
        self.main = main
        self.windSpeed = windSpeed
        self.clouds = clouds
        self.cityId = cityId
        self.cityName = cityName
    }
}


