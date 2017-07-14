//
//  Firebase.swift
//  Weather
//
//  Created by Евгений on 09.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit



class Firebase {
    var rootRef: DatabaseReference!
    var userCities:[City] = []  // temporary array of cities from database
    
    // Connection to Firebase
    
    func connectionToFirebase(completionHandler: @escaping (String) -> Void) {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return completionHandler("")  }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) {[weak weakself = self] (user, error) in
            if error != nil {
                print(error.debugDescription)
                return completionHandler("")
            }
            
            UserDefaults.standard.set(user?.uid, forKey: "uid") // safe UID of registred user to memory
            UserDefaults.standard.synchronize()

            return completionHandler(user!.email!)
        }
    }
    
    
    // disconnection to Firebase
    
    func disconnectionToFirebase() -> Bool {
        FBSDKLoginManager().logOut()    //disconnection to facebook
        do{
            try Auth.auth().signOut()   //disconnection to firebase
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    // add new selected city by user to Firevase
    
    func addNewCity(with info: City){
        
        let user = UserDefaults.standard.string(forKey: "uid") // getting UID
        
        rootRef = Database.database().reference()
        let userRef = rootRef.child(user!)          // UID - NameOfCity - AllCityInfo
        let childRef = userRef.child(info.name!)
        childRef.setValue(info.toAnyObject())
    }
    
    //cheking if some changes were done in Firebase
    
    func observeChangesInDatabase(completionHandler: @escaping ([City]) -> Void){
        
        let user = UserDefaults.standard.string(forKey: "uid")
        rootRef = Database.database().reference()
        let userRef = rootRef.child(user!)
        
        userRef.observe(.value, with: {[weak weakself = self] (snapshot) in
            
            if snapshot.childrenCount > 0 {
                
                weakself?.userCities.removeAll()    //remove all values from temporary array
                
                for item in snapshot.children {
                    let currentCity = City(snapshot: item as! DataSnapshot)
                    weakself?.userCities.append(currentCity)    // update temporary array with new values
                }
            }
            else {
                weakself?.userCities.removeAll()    // else return empty array
            }
            return completionHandler((weakself?.userCities)!)
        })

    }
    
}
