//
//  MoreInfoController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/8/23.
//

import UIKit
import FirebaseAuth

class MoreInfoController : BaseViewController {
    
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var vinNumberField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    /**
     Update user with new data inputted and transition to home page
     */
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let data: [UserManager.UserField: Any] = [
            UserManager.UserField.birthdate: birthdatePicker.date,
            UserManager.UserField.vin: vinNumberField.text!
        ]
        UserManager.shared.updateData(data) { error in
            if let error = error {
                // Handle the error
                print("Error updating user data: \(error)")
            } else {
                // Data was updated successfully
                print("User data updated")
                self.performSegue(withIdentifier: "goHome", sender: self)
            }
        }
    }
    
}
