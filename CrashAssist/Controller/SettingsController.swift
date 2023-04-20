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
        UserManager.shared.signOut()
        self.performSegue(withIdentifier: "goLandingFromSettings", sender: self)
    }
    
}
