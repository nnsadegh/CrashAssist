//
//  SettingsController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit
import FirebaseAuth

class SettingsController: BaseViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            // User is signed out.
            performSegue(withIdentifier: "goToLanding", sender: self)
        } catch let error as NSError {
            print("Error signing out: %@", error)
        }
    }
    
}
