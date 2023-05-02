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
    
    @IBAction func clearLogDataButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete all logs?", message: "Are you sure you want to delete all logs?", preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            LogManager.shared .deleteAllLogs {
                return
            }
        }
        alertController.addAction(deleteAction)

        // To show the alert from the bottom of the screen, set the popoverPresentationController's sourceView and sourceRect properties
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        LogManager.shared.deleteAllLogs {
            UserManager.shared.deleteUser { error in
                if let error = error {
                    print("Error deleting user: \(error)")
                } else {
                    self.performSegue(withIdentifier: "goLandingFromSettings", sender: self)
                }
            }
        }
    }
    
}
