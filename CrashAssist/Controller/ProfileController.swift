//
//  ProfileController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit

class ProfileController: BaseViewController {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var birthdateText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        FSUtil.shared.getUser() { [self] result in
            switch result {
                case .success(let user):
                // Do something with the user object
                    nameText.text = user.name
                    emailText.text = user.email
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let bd = user.birthdate {
                        birthdateText.text = dateFormatter.string(from: bd)
                    } else {
                        birthdateText.text = "Enter a birthday!"
                    }
                case .failure(let error):
                    print("Error fetching user: \(error)")
                }
        }
    }
    
    
}
