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
    }
    
    
    func loginDesign (button: UIButton) {   // making design for FB button
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
                                    weakself2?.performSegue(withIdentifier: "showSelectedCities", sender: nil)
                                }
                            }
                        }
                        
                        
                    }
                }
            }
        }
}


