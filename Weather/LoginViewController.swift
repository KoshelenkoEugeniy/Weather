//
//  ViewController.swift
//  Weather
//
//  Created by Евгений on 01.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {                    //, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var FBLoginButton: UIButton!
    
    @IBAction func FBLogIn(_ sender: UIButton) {
        handleCustomFBLogin()
    }
    
    var firebaseLogin = Firebase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginDesign(button: FBLoginButton)
        
        //FBLoginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        /*
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        
        let permissionsToRead = ["public_profile", "email"]
        loginButton.readPermissions = permissionsToRead
        
        
        let widthOfButton = loginButton.frame.width + 60
        let heightOfButton = loginButton.frame.height + 15
        let verticalPosition: CGFloat = 4.0
        
        let positionOfFrame = self.view.center.y - self.view.center.y / verticalPosition
        let positionX = self.view.center.x - widthOfButton / 2
        let positionY = self.view.center.y - heightOfButton / 2
        let finalPositionY = positionY + positionOfFrame
        
        loginButton.frame = CGRect(x: positionX, y: finalPositionY, width: widthOfButton, height: heightOfButton)
        view.addSubview(loginButton)*/
    }

    
    func loginDesign (button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.6
        
        let widthOfButton = button.frame.width + 60
        let heightOfButton = button.frame.height + 15
        let verticalPosition: CGFloat = 4.0
        
        let positionOfFrame = self.view.center.y - self.view.center.y / verticalPosition
        let positionX = self.view.center.x - widthOfButton / 2
        let positionY = self.view.center.y - heightOfButton / 2
        let finalPositionY = positionY + positionOfFrame
        
        button.frame = CGRect(x: positionX, y: finalPositionY, width: widthOfButton, height: heightOfButton)
        
        FBLoginButton.setTitle("Facebook login", for: .normal)
        FBLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        FBLoginButton.setTitleColor(.white, for: .normal)
    }
    
    //=========== custom FB button ================
    
    func handleCustomFBLogin () {
        
        //if FBLoginButton.titleLabel?.text == "Facebook login" {
        
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { [weak weakself = self] (result, error) in
            
                if (error != nil) {
                    NSLog("Error in Facebook Login \(error!.localizedDescription)")
                    return
                } else if (result?.isCancelled)! {
                    NSLog("User Canceled The Login")
                    return
                } else {
                    if result!.grantedPermissions.contains("email") {
                        
                        weakself?.firebaseLogin.connectionToFirebase(){ [weak weakself2 = self] (feedback) in
                            if feedback != "" {
                                DispatchQueue.main.async {
                                    //weakself2?.FBLoginButton.setTitle("Log out", for: .normal)
                                    weakself2?.performSegue(withIdentifier: "showSelectedCities", sender: nil)
                                }
                            }
                        }
                        
                        
                    }
                }
            }
        //} else {
            //FBSDKLoginManager().logOut()
            //FBLoginButton.setTitle("Facebook login", for: .normal)
        //}
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {
            switch identifier {
            case "showSelectedCities":
                
                var destinationVC = segue.destination
                
                if let navcon = destinationVC as? UINavigationController {
                    destinationVC = navcon.visibleViewController ?? destinationVC
                }
                
                if let vc = destinationVC as? SelectedCitiesTableViewController {
                   
                }
                
            default:
                print("another identifier")
            }
        }
    }*/
    
    
    
    /*
    //============= standart FB buttom ==============
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook!")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if (error != nil) {
            NSLog("Error in Facebook Login \(error.localizedDescription)")
            return
        } else if result.isCancelled {
            NSLog("User Canceled The Login")
            return
        } else {
            if result.grantedPermissions.contains("email") {
                //showEmailFB()
            }
        }
    
    }
    //===================================================
    */

    
    /*
    func connectionToFirebase(completionHandler: @escaping (String) -> Void) {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return completionHandler("") }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print(error.debugDescription)
                return completionHandler("")
            }
            
            print ("success", user!.email!)
            return completionHandler(user!.email!)
        }
        */
        
        
        /*
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print(error.debugDescription)
                return completionHandler(false)
            }
            print(result ?? "no info")
            return completionHandler(true)
        }*/
    //}
}


