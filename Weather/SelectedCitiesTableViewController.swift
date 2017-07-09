//
//  SelectedCitiesTableViewController.swift
//  Weather
//
//  Created by Евгений on 05.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit
import Firebase


class SelectedCitiesTableViewController: UITableViewController {
    var firebase = Firebase()
    var selectedCities: [City] = []
    var weatherForCities: [weatherForecast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
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
            weatherCell.weatherIcon = forecast.weather.icon
            weatherCell.cityName.text = forecast.cityName
            weatherCell.cityTemperature.text = String(describing: forecast.main.temp)
        }
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
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

    
    @IBAction func unwindFromCitiesListAddNewCity(_ segue: UIStoryboardSegue){
        
        if let identifier = segue.identifier {
            switch identifier {
            case "unwindNewCity":
                
                var sourceVC = segue.source
                
                if let navcon = sourceVC as? UINavigationController {
                    sourceVC = navcon.visibleViewController ?? sourceVC
                }
                
                if let vc = sourceVC as? CitiesListTableViewController {
                    selectedCities.removeAll()
                    firebase.observeChangesInDatabase(completionHandler: { [weak weakself = self] (cities) in
                        weakself?.selectedCities = cities
                        
                    })
                    
                }
                
            default:
                print("another identifier")
            }
        }

    }

}
