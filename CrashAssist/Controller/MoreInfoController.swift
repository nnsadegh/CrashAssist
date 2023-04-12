//
//  MoreInfoController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/8/23.
//

import UIKit

class MoreInfoController : BaseViewController {
    
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var vinNumberField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        FSUtil.shared.getUser { [self] result in
            switch result {
                case .success(let user):
                    // Do something with the user object
                    var updated = user
                    updated.birthdate = birthdatePicker.date
                    if let vin = vinNumberField.text, !vin.isEmpty {
                        updated.vin = vin
                    }
                    FSUtil.shared.updateUser(user: user) { error in
                        if let error = error {
                            print(error)
                            return
                        }
                    }
                    performSegue(withIdentifier: "goHome", sender: self)
                case .failure(let error):
                    print("Error fetching user: \(error)")
                }
        }
    }
    
}
