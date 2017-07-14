//
//  SettingsViewController.swift
//  Weather
//
//  Created by Евгений on 05.07.17.
//  Copyright © 2017 Koshelenko Eugeniy. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutDesign(button: FBLogoutButton)
    }
    
    var firebase = Firebase()
    
    @IBOutlet weak var FBLogoutButton: UIButton!
    
    @IBAction func FBLogOut(_ sender: UIButton) {
        let success = firebase.disconnectionToFirebase()
        if success == true {
            performSegue(withIdentifier: "showLogin", sender: nil)
        } else { return }
    }
    
    
    @IBAction func cancellation(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func logoutDesign (button: UIButton) {
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
        
        FBLogoutButton.setTitle("Log out", for: .normal)
        FBLogoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        FBLogoutButton.setTitleColor(.white, for: .normal)
    }
    

}
