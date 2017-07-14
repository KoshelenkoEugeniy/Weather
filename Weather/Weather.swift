//
//  Weather.swift
//  Weather
//
//  Created by Евгений on 09.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import Foundation
import UIKit

// Struct describes weather forecast according to OpenWeatherMap

struct Weather {
    var description: String?
    var iconName: String?
    
    init(){
        self.description = nil
        self.iconName = nil
    }
    
    init(description: String?, iconName: String?){
        self.description = description
        self.iconName = iconName
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
    var weather: Weather
    var main: Main
    var windSpeed: Float?
    var clouds: Float?
    var cityId: Int?
    var cityName: String?
    
    init(){
        self.weather = Weather()
        self.main = Main()
        self.windSpeed = nil
        self.clouds = nil
        self.cityId = nil
        self.cityName = nil
    }
    
    init(weather: Weather, main: Main, windSpeed: Float?, clouds: Float?, cityId: Int?, cityName: String?){
        self.weather = weather
        self.main = main
        self.windSpeed = windSpeed
        self.clouds = clouds
        self.cityId = cityId
        self.cityName = cityName
    }
}


