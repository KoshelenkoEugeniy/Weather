//
//  City.swift
//  Weather
//
//  Created by Евгений on 06.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import Foundation
import Firebase

// struct describes each city according to OpenWeatherMap

struct City {
    
    var id: Int?
    var name: String?
    var country: String?
    var coord: Coordinates?
    var ref: DatabaseReference?     // reference on object in Firebase's database
    
    init(){
        self.id = nil
        self.name = nil
        self.country = nil
        self.coord = Coordinates()
        self.ref = nil
    }
    
    init(id: Int?, name: String?, country:String?, coord:Coordinates?) {
        self.id = id
        self.name = name
        self.country = country
        self.coord = coord
    }
    
    init(snapshot: DataSnapshot) {                                  //initialization according to Firebase
        let snapshotValue = snapshot.value as? [String: AnyObject]
        name = snapshotValue?["name"] as? String
        id = snapshotValue?["id"] as? Int
        country = snapshotValue?["country"] as? String
        ref = snapshot.ref
        
        let coordValue = snapshotValue?["coord"] as? [String: AnyObject]
        let coordLon = coordValue?["lon"] as? Float
        let coordLat = coordValue?["lat"] as? Float
        let coordinates = Coordinates(lon: coordLon, lat: coordLat)
        coord = coordinates
    }
    
    func toAnyObject() -> Any {     //method for writing data to Firebase
        return [
            "id": id,
            "name": name,
            "country": country,
            "coord": [
                "lon": coord?.lon,
                "lat":coord?.lat
            ]
        ]
    }
}


// Struct describes coordinates of each city

struct Coordinates {
    var lon: Float?
    var lat: Float?

    init (){
        lon = nil
        lat = nil
    }
    
    init(lon: Float?, lat: Float?){
        self.lat = lat
        self.lon = lon
    }
}
