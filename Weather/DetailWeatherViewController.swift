//
//  DetailWeatherViewController.swift
//  Weather
//
//  Created by Евгений on 05.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit

import MapKit

class DetailWeatherViewController: UIViewController {
    
    var weatherInCity: [weatherForecast] = []   //detailed weather for city which should be shown
    var city: [City] = []                       //city which should be shown, its coordinates
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if weatherInCity[0].cityName != nil {
            
            switch weatherInCity[0].weather.iconName! {     // depending on icon name from OpenWeatherMap set background
            case "01d", "01n", "02d", "02n":
                backgroundImage.image = #imageLiteral(resourceName: "sun")
            case "03d", "03n", "04d", "04n":
                backgroundImage.image = #imageLiteral(resourceName: "clouds")
            case "09d", "09n", "10d", "10n", "11d", "11n":
                backgroundImage.image = #imageLiteral(resourceName: "rain")
            case "13d", "13n":
                backgroundImage.image = #imageLiteral(resourceName: "snow")
            default:
                backgroundImage.image = #imageLiteral(resourceName: "fog")
            }
            
            nameOfCity.text = weatherInCity[0].cityName
            
            briefWeatherDescription.text = weatherInCity[0].weather.description
            
            image.downloadImage(from: "http://openweathermap.org/img/w/\(weatherInCity[0].weather.iconName!).png") //download icon of weather
            
            if weatherInCity[0].main.temp! > 0 {
                temperature.text = "+\(weatherInCity[0].main.temp!) ℃"
            } else {
                temperature.text = "\(weatherInCity[0].main.temp!) ℃"
            }
            
            pressure.text = "\(weatherInCity[0].main.pressure!) hPa"
            humidity.text = "\(weatherInCity[0].main.humidity!) %"
            windSpeed.text = "\(weatherInCity[0].windSpeed!) meter/sec"
            clouds.text = "\(weatherInCity[0].clouds!) %"
            
            // set coordinates and region for Map
            
            let lat: Double = Double((city[0].coord?.lat)!)
            let lon: Double = Double((city[0].coord?.lon)!)
            
            let initialLocation = CLLocation(latitude: lat, longitude: lon)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, 10000.0, 10000.0)
            cityMap.setRegion(coordinateRegion, animated: true)
            
        }
        
    }
    
    @IBAction func cancellation(_ sender: UIBarButtonItem) {    //if push on Cancell
       dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var nameOfCity: UILabel!

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var briefWeatherDescription: UILabel!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var pressure: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windSpeed: UILabel!
    
    @IBOutlet weak var clouds: UILabel!
    
    @IBOutlet weak var cityMap: MKMapView!
    
    @IBOutlet weak var backgroundImage: UIImageView!

}
