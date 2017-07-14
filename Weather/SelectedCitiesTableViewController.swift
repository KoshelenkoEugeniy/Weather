//
//  SelectedCitiesTableViewController.swift
//  Weather
//
//  Created by Евгений on 05.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON


class SelectedCitiesTableViewController: UITableViewController {
    var firebase = Firebase()
    var selectedCities: [City] = []     // array of selected cities
    var weatherForCities: [weatherForecast] = []    // array with weather for selected cities
    
    var isUserWaiting:Bool = false  // if user is still waiting
    let loadingView = UIView()      // view for spinner
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    var dataTask: URLSessionDataTask?
    let session = URLSession.shared
    
    // OpenWeatherMap allows getting info maximum for 20 cities per one request
    // so if elements in selectedCities[] would be more than 20, array divided on subarrays
    
    var startIndex: Int = 0 // startindex of current subarray
    var endIndex: Int = 0   // endindex of current subarray
    var isLessThan20Cities: Bool = true // flag that shows if in array more than 20 cities
    var itWasTheLastPartOfCities: Bool = true //flag that shows if it was the last subarray
    
    var countOfBlocks: Int = 0  //counter of subarrays that I have get from Firebase
    var inTheMiddleOfGettingWeather: Bool = false   // flag that shows if view controller is making now an urlreguest for some subarray
    var cityIndex = -1  //index of selected city for showing detailed weather
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Init()
    }
    
    func Init(){
        setLoadingScreen()
        isUserWaiting = true
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isUserWaiting = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedCity", for: indexPath)

        let forecast: weatherForecast = weatherForCities[indexPath.row]
        
        if let weatherCell = cell as? SelectedCitiesTableViewCell {
            
            // downloading small icon of weather according to icon name
            
            weatherCell.weatherIcon.downloadImage(from: "http://openweathermap.org/img/w/\(forecast.weather.iconName!).png")
            
            weatherCell.cityName.text = forecast.cityName!
            
            if forecast.main.temp! > 0 {
                weatherCell.cityTemperature.text = "+" + String(describing: forecast.main.temp!) + " ℃"
            } else {
                weatherCell.cityTemperature.text = String(describing: forecast.main.temp!) + " ℃"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cityIndex = indexPath.row
        self.performSegue(withIdentifier: "detailWeather", sender: self)    //perform segue on detailed Weather forecast
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentCity = selectedCities[indexPath.row] //remove city from Firebase accoding to reference.
            currentCity.ref?.removeValue()
        }
    }
    
    //---
    
    func loadData(){
        
        firebase.observeChangesInDatabase(completionHandler: { [weak weakself = self] (cities) in
            
            if cities.count == 0 {
                
                // if current user doesn't has any saved city in Firebase, table view reloaded
                
                DispatchQueue.main.async {
                    weakself?.weatherForCities.removeAll()
                    weakself?.selectedCities.removeAll()
                    weakself?.removeLoadingScreen()
                    weakself?.tableView.reloadData()
                }
            }
            else {
    
                weakself?.selectedCities.removeAll()
                weakself?.selectedCities = cities       // else save array of users cities and if user is still waiting
                if weakself?.isUserWaiting == true {
                    
                    if weakself?.inTheMiddleOfGettingWeather == false {         // create a url request
                        weakself?.createSession(with: cities, completionHandler:  {[weak weakself2 = self](feedback) in
                            if feedback == "done" && weakself2?.isUserWaiting == true{
                                
                                if weakself2?.itWasTheLastPartOfCities == true {
                                    
                                    weakself2?.startIndex = 0
                                    weakself2?.endIndex = 0
                                    weakself2?.itWasTheLastPartOfCities = true
                                    weakself2?.isLessThan20Cities = true
                                    weakself2?.inTheMiddleOfGettingWeather = false
                                    
                                    DispatchQueue.main.async {
                                        weakself2?.tableView.reloadData()   // and shows results
                                        weakself2?.removeLoadingScreen()
                                    }
                                } else {
                                    weakself2?.inTheMiddleOfGettingWeather = false  // else if not all cities were returned by Firebase
                                                                                    // making next request
                                    weakself2?.loadData()
                                }
                            }
                        })
                    }
                }
            }
            
        })
    }

    
    
    
    func setLoadingScreen() {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Updating..."
        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.tableView.addSubview(loadingView)
    }

    func removeLoadingScreen() {
        spinner.stopAnimating()
        loadingLabel.isHidden = true
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
                case "detailWeather":
                    
                                    var destinationVC = segue.destination
                    
                                    if let navcon = destinationVC as? UINavigationController {
                                        destinationVC = navcon.visibleViewController ?? destinationVC
                                    }
                    
                                    if let vc = destinationVC as? DetailWeatherViewController {
                                        if cityIndex != -1 {
                                            vc.city.append(selectedCities[cityIndex])                   //determine city that should be shown with detailed forecast
                                            vc.weatherInCity.append(weatherForCities[cityIndex])
                                        }
                                    }
                default:
                    print("another identifier")
            }
        }
    }

    // method determines subarray of cities that shoud be send to Firebase
    
    func divideArrayOnParts (of cities:[City]) -> [City]{
        
        var subarrayCities:[City] = []
        
        if cities.count == 0 {
            subarrayCities.removeAll()
        } else {
            if startIndex == 0 && endIndex == 0 {
                
                inTheMiddleOfGettingWeather = true
                
                weatherForCities.removeAll()
                
                let floatCount = Float(cities.count)
                
                var quantityOfCycles = floatCount / 20.000
                
                quantityOfCycles = quantityOfCycles.rounded(.up)
                
                let count = Int(quantityOfCycles)
                
                countOfBlocks = count   // determines count of request cycles
                
                if count == 1 {
                    startIndex = 0
                    endIndex =  cities.count - 1
                } else {
                    startIndex = 0
                    endIndex =  19
                    isLessThan20Cities = false
                    itWasTheLastPartOfCities = false
                }
            } else {
                startIndex = endIndex + 1
                if endIndex + 20 >= cities.count {
                    endIndex = cities.count - 1
                } else {
                    endIndex = endIndex + 20
                }
            }
            
            if startIndex > endIndex {
                subarrayCities.removeAll()
            } else {
                subarrayCities.append(contentsOf: cities[startIndex...endIndex])
            }

        }
        
        return subarrayCities   // return subarray of cities
    }
    
    
    func createSession (with cities:[City], completionHandler: @escaping (String) -> Void) {
        
        var weatherURL: URL? = nil
        var tempStr = ""
        let weatherApiKey:String = UserDefaults.standard.string(forKey: "weatherKey")!
        
        let subarrayCities = divideArrayOnParts(of: cities)
        
        if subarrayCities.count == 0 {
            completionHandler("error")
        } else {
            
            for i in 0...subarrayCities.count - 1 {
                if i == subarrayCities.count - 1 {
                    tempStr = tempStr + "\(subarrayCities[i].id!)"      // making a list of cities IDs
                } else {
                    tempStr = tempStr + "\(subarrayCities[i].id!)" + ","
                }
            }
            
            weatherURL = URL(string: "http://api.openweathermap.org/data/2.5/group?id=\(tempStr)&units=metric&APPID=\(weatherApiKey)")
            
                dataTask = session.dataTask(with: weatherURL!, completionHandler: { [weak weakself = self] (data, response, error) in
                    
                    if let error = error {
                        completionHandler("session error: \(error.localizedDescription)")
                    }
                    else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            
                            var temp: [weatherForecast] = []
                            
                            temp = (weakself?.parseWeather(data))!
                            
                            if weakself?.isLessThan20Cities == true {   //if less than 20 cities - return the whole forecast
                                weakself?.weatherForCities = temp
                            } else {
                                weakself?.weatherForCities.append(contentsOf: temp)
                                
                                weakself?.countOfBlocks = (weakself?.countOfBlocks)! - 1    // decreasing counts of request cycles
                                if weakself?.countOfBlocks == 0 {                           // if countOfBlocks = 0 than it was a lst part of cities and it is possible to show all forecasts
                                    
                                    weakself?.itWasTheLastPartOfCities = true
                                }
                            }
                            
                            completionHandler("done")
                        }
                    }
                })
                dataTask?.resume()
        }
    }

    
    // parsing weather forecast with the help of SwiftyJson
    
    func parseWeather(_ data: Data?) -> [weatherForecast] {
        
        var tempWeatherForecast = weatherForecast()
        var tempWeather = Weather()
        var tempMain = Main()
        
        var arrayOfWeathers:[weatherForecast] = []
        
        let clearJson = JSON(data: data!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
        
        let numberOfCities = clearJson["cnt"].intValue
        
        for i in 0..<numberOfCities {
            
            tempMain.humidity = clearJson["list"][i]["main"]["humidity"].floatValue
            tempMain.pressure = clearJson["list"][i]["main"]["pressure"].floatValue
            tempMain.temp = clearJson["list"][i]["main"]["temp"].floatValue
            
            for (_,subJson):(String, JSON) in clearJson["list"][i]["weather"] {
                tempWeather.description = subJson["description"].string
                tempWeather.iconName = subJson["icon"].string
            }
            
            tempWeatherForecast.cityId = clearJson["list"][i]["id"].intValue
            tempWeatherForecast.cityName = clearJson["list"][i]["name"].stringValue
            tempWeatherForecast.clouds = clearJson["list"][i]["clouds"]["all"].floatValue
            tempWeatherForecast.windSpeed = clearJson["list"][i]["wind"]["speed"].floatValue
            tempWeatherForecast.main = tempMain
            tempWeatherForecast.weather = tempWeather
            
            arrayOfWeathers.append(tempWeatherForecast)
        }
        
        return arrayOfWeathers
    }

}

// extension for downloading the weather icon

extension UIImageView {
    func downloadImage(from url:String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print (error.debugDescription)
            } else {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
            
        }
        task.resume()
    }
}
