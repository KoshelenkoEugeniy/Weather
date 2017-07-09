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
    var userCities:[City] = []
    var email: String = ""
    
    func connectionToFirebase(completionHandler: @escaping (String) -> Void) {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return completionHandler("")  }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) {[weak weakself = self] (user, error) in
            if error != nil {
                print(error.debugDescription)
                return completionHandler("")
            }
            
            print ("success", user!.email!)
            weakself?.email = user!.email!
            
            UserDefaults.standard.set(user?.uid, forKey: "uid")
            UserDefaults.standard.synchronize()

            return completionHandler(user!.email!)
        }
    }
    
    func disconnectionToFirebase() -> Bool {
        FBSDKLoginManager().logOut()    //facebook
        do{
            try Auth.auth().signOut()   // firebase
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    func addNewCity(with info: City){
        let user = UserDefaults.standard.string(forKey: "uid")
        
        rootRef = Database.database().reference()
        let userRef = rootRef.child(user!)
        let childRef = userRef.child(info.name!)
        childRef.setValue(info.toAnyObject())
    }
    
    
    func observeChangesInDatabase(completionHandler: @escaping ([City]) -> Void){
        
        let user = UserDefaults.standard.string(forKey: "uid")
        rootRef = Database.database().reference()
        let userRef = rootRef.child(user!)
        
        userRef.observe(.value, with: {[weak weakself = self] (snapshot) in
            if snapshot.childrenCount > 0 {
                weakself?.userCities.removeAll()
                
                for item in snapshot.children {
                    let currentCity = City(snapshot: item as! DataSnapshot)
                    weakself?.userCities.append(currentCity)
                }
            }
            return completionHandler((weakself?.userCities)!)
        })
    }
    
}
