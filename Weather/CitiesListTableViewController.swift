//
//  CitiesListTableViewController.swift
//  Weather
//
//  Created by Евгений on 05.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit

class CitiesListTableViewController: UITableViewController{
    
    var Cities: [City] = []
    var cityNames: [String] = []
    var selectedCity = -1
    
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var isUserWaiting:Bool = false
    
    var firebase = Firebase()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLoadingScreen()
        
        isUserWaiting = true
        
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isUserWaiting = false
    }
    
   

    
    func loadData(){
        parseUkrainianCities { [weak weakself = self] (sortedCities, sortedCityNames) in
            weakself?.Cities = sortedCities
            weakself?.cityNames = sortedCityNames
            
            if weakself?.isUserWaiting == true {
                if (weakself?.Cities.count)! > 0 {
                    DispatchQueue.main.async {
                        weakself?.tableView.reloadData()
                        weakself?.removeLoadingScreen()
                    }
                }
            }
        }
    }


    @IBAction func cancellation(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cityNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityName", for: indexPath)

        let city: City = Cities[indexPath.row]
        
        if let cityCell = cell as? CitiesListTableViewCell {
            cityCell.nameOfCity.text = city.name!
            cityCell.nameOfCountry.text = city.country!
        }
        
        return cell
    }
    // -------------------
    
    
    func setLoadingScreen() {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
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


   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "unwindNewCity" {
            let currentCity = Cities[selectedCity]
            firebase.addNewCity(with: currentCity)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCity = indexPath.row
        if navigationItem.rightBarButtonItem?.isEnabled == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func parseUkrainianCities(completionHandler: @escaping ([City],[String]) -> Void) {
        
        var id: Int?
        var name: String?
        var country: String?
        var coord: Coordinates?
        var lon: Float?
        var lat: Float?
        var listOfCities: [City] = []
        var listOfCityNames: [String] = []
        
        let path = Bundle.main.path(forResource: "CitiesList_OpenWeatherMap", ofType: "json", inDirectory: "Cities")
        
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            
            let json = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
                
            let array = json as? [AnyObject]
            
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                for eachElement in array! {
                    
                    let cityInfo = eachElement as? [String: AnyObject]
                    
                    id = cityInfo?["id"] as? Int
                    name = cityInfo?["name"] as? String
                    country = cityInfo?["country"] as? String
                    
                    let tempCoord = cityInfo?["coord"] as? [String:AnyObject]
                    
                    lon = tempCoord?["lon"] as? Float
                    lat = tempCoord?["lat"] as? Float
                    coord = Coordinates(lon: lon, lat: lat)
                    
                    if country == "UA" {
                        let newCity = City(id: id, name: name, country: country, coord: coord)
                        listOfCities.append(newCity)
                        listOfCityNames.append(newCity.name!)
                    }
                }
                
                if listOfCities.count > 0 {
                    listOfCities = listOfCities.sorted(by: { (city1, city2) -> Bool in
                        return city1.name! < city2.name!
                    })
                    
                    listOfCityNames = listOfCityNames.sorted(by: { (name1, name2) -> Bool in
                        return name1 < name2
                    })
                    
                    completionHandler(listOfCities, listOfCityNames)
                }
                else {
                    completionHandler([],[])
                }

            }
            
        }
        catch {
            print(error.localizedDescription)
        }
        
        completionHandler([],[])
    }
}
