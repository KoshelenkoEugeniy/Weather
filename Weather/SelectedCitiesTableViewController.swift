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
    var selectedCities: [City] = []
    var weatherForCities: [weatherForecast] = []
    var isUserWaiting:Bool = false
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var dataTask: URLSessionDataTask?
    let session = URLSession.shared
    var startIndex: Int = 0
    var endIndex: Int = 0
    var isLessThan20Cities: Bool = true
    var itWasTheLastPartOfCities: Bool = true
    let mySerialQueue = DispatchQueue(label: "com.OpenWeatherMap.MySerial", qos: .userInitiated)
    var countOfBlocks: Int = 0
    var inTheMiddleOfGettingWeather: Bool = false
    var countOfSections: Int = 1
    
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
 
    
    func loadData(){
        
        firebase.observeChangesInDatabase(completionHandler: { [weak weakself = self] (cities) in
            
            if cities.count == 0 {
                //weakself?.countOfSections = 1
                DispatchQueue.main.async {
                    weakself?.removeLoadingScreen()
                    weakself?.tableView.reloadData()
                }
            }
            else {
                weakself?.countOfSections = 1
                
                weakself?.selectedCities.removeAll()
                weakself?.selectedCities = cities
                if weakself?.isUserWaiting == true {
                    
                    if weakself?.inTheMiddleOfGettingWeather == false {
                        weakself?.createSession(with: cities, completionHandler:  {[weak weakself2 = self](feedback) in
                            if feedback == "done" && weakself2?.isUserWaiting == true{
                                
                                if weakself2?.itWasTheLastPartOfCities == true {
                                    
                                    weakself2?.startIndex = 0
                                    weakself2?.endIndex = 0
                                    weakself2?.itWasTheLastPartOfCities = true
                                    weakself2?.isLessThan20Cities = true
                                    weakself2?.inTheMiddleOfGettingWeather = false
                                    
                                    DispatchQueue.main.async {
                                        weakself2?.tableView.reloadData()
                                        weakself2?.removeLoadingScreen()
                                    }
                                } else {
                                    weakself2?.inTheMiddleOfGettingWeather = false
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }*/
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            let currentCity = selectedCities[indexPath.row]
             currentCity.ref?.removeValue()
            
            
            //weatherForCities.remove(at: indexPath.row)
            //selectedCities.remove(at: indexPath.row)
            //print("\(indexPath.row) \(indexPath.section)")
            //tableView.deleteRows(at: [indexPath], with: .fade)
            //tableView.reloadData()
            
           
            
            
            Init()
        }
        
        
        //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
                case "addNewCity":
                    
                                    var destinationVC = segue.destination
                    
                                    if let navcon = destinationVC as? UINavigationController {
                                        destinationVC = navcon.visibleViewController ?? destinationVC
                                    }
                    
                                    if let vc = destinationVC as? CitiesListTableViewController {
                                        
                                    }

                default:
                    print("another identifier")
            }
        }
    }*/

    
    //@IBAction func unwindFromCitiesListAddNewCity(_ segue: UIStoryboardSegue){
       /*
        if let identifier = segue.identifier {
            switch identifier {
            case "unwindNewCity":
                
                var sourceVC = segue.source
                
                if let navcon = sourceVC as? UINavigationController {
                    sourceVC = navcon.visibleViewController ?? sourceVC
                }
                
                if let vc = sourceVC as? CitiesListTableViewController {
                    
                    firebase.observeChangesInDatabase(completionHandler: { [weak weakself = self] (cities) in
                        weakself?.selectedCities.removeAll()
                        weakself?.selectedCities = cities
                        weakself?.createSession(with: cities, completionHandler:  {[weak weakself2 = self](feedback) in
                            if feedback == "done" {
                                DispatchQueue.main.async {
                                    weakself2?.tableView.reloadData()
                                }
                            }
                        })
                    })
                    
                }
                
            default:
                print("another identifier")
            }
        }*/

    //}
    
    
    
    
    
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
                
                countOfBlocks = count
                
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
        
        return subarrayCities
        
        /*
        for i in 0 ..< count {
            
            subarrayCities.removeAll()
            
            if (i * 20 + 19) >= cities.count {
                startIndex = 20 * i
                endIndex = cities.count - 1
            } else {
                startIndex = 20 * i
                endIndex = i * 20 + 19
                if count > 1 {
                    isLessThan20Cities = false
                }
            }
        }*/
    }
    
    
    
    
    func createSession (with cities:[City], completionHandler: @escaping (String) -> Void) {
        
        var weatherURL: URL? = nil
        var tempStr = ""
        let weatherApiKey:String = UserDefaults.standard.string(forKey: "weatherKey")!
        
        let subarrayCities = divideArrayOnParts(of: cities)
        
        if subarrayCities.count == 0 {
            completionHandler("error")
        } else {
        /*

        var subarrayCities:[City] = []
        
        let floatCount = Float(cities.count)
        
        var quantityOfCycles = floatCount / 20.000
        
        quantityOfCycles = quantityOfCycles.rounded(.up)
        
        let count = Int(quantityOfCycles)
        
        countOfBlocks = count
        
        for i in 0 ..< count {
            
            subarrayCities.removeAll()
            
            if (i * 20 + 19) >= cities.count {
                startIndex = 20 * i
                endIndex = cities.count - 1
            } else {
                startIndex = 20 * i
                endIndex = i * 20 + 19
                if count > 1 {
                    isLessThan20Cities = false
                    itWasTheLastPartOfCities = false
                }
            }
            
            subarrayCities.append(contentsOf: cities[startIndex...endIndex])*/
            
            for i in 0...subarrayCities.count - 1 {
                if i == subarrayCities.count - 1 {
                    tempStr = tempStr + "\(subarrayCities[i].id!)"
                } else {
                    tempStr = tempStr + "\(subarrayCities[i].id!)" + ","
                }
            }
            
            weatherURL = URL(string: "http://api.openweathermap.org/data/2.5/group?id=\(tempStr)&units=metric&APPID=\(weatherApiKey)")
            
            //mySerialQueue.sync {
                dataTask = session.dataTask(with: weatherURL!, completionHandler: { [weak weakself = self] (data, response, error) in
                    
                    if let error = error {
                        completionHandler("session error: \(error.localizedDescription)")
                    }
                    else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            
                            var temp: [weatherForecast] = []
                            
                            temp = (weakself?.parseWeather(data))!
                            
                            if weakself?.isLessThan20Cities == true {
                                weakself?.weatherForCities = temp
                            } else {
                                weakself?.weatherForCities.append(contentsOf: temp)
                                
                                weakself?.countOfBlocks = (weakself?.countOfBlocks)! - 1
                                if weakself?.countOfBlocks == 0 {
                                    weakself?.itWasTheLastPartOfCities = true
                                }
                            }
                            
                            completionHandler("done")
                            
                            
                            
                        }
                    }
                })
                dataTask?.resume()
            //}
            
        }
    }

    
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
            
            //print("\(clearJson["list"][i])")
            //print("\(clearJson["list"][i]["weather"].arrayValue.map({ $0["description"].stringValue}))")
            //print("\(clearJson["list"][i]["main"]["temp"].floatValue)")
            
            //print("\(tempWeatherForecasr.cityId!)")
            //print("\(tempWeatherForecasr.cityName!)")
            //print("\(tempWeatherForecasr.clouds!)")
            //print("\(tempWeatherForecasr.windSpeed!)")
            
            arrayOfWeathers.append(tempWeatherForecast)
        }
        
        return arrayOfWeathers
    }

}


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
