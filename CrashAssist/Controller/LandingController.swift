//
//  LandingViewController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/6/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuthUI
import FirebaseEmailAuthUI
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI

class LandingController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goHomeFromLogin", sender: self)
        }
    }
    
    
    @IBAction func loginButtonDidTapped(_ sender: UIButton) {
        // Create default Auth UI
        let authUI = FUIAuth.defaultAuthUI()
        
        // Check that it isn't nil
        guard authUI != nil else {
            return
        }
        
        // Set delegate and specify sign in options
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
          FUIEmailAuth(),
          FUIGoogleAuth(authUI: FUIAuth.defaultAuthUI()!),
          FUIFacebookAuth(authUI: FUIAuth.defaultAuthUI()!),
        ]
        authUI?.providers = providers
        
        // Get the auth view controller and present it
        let authViewController = authUI!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
}

extension BaseViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        // Check for error
        guard error == nil else {
            return
        }
        
        FSUtil.shared.userExists() { (exists) in
            if exists {
                // Document exists
                self.performSegue(withIdentifier: "goHomeFromLogin", sender: self)
            } else {
                // Document does not exist
                // Transition to home
                self.performSegue(withIdentifier: "goMoreFromLogin", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let currUser = Auth.auth().currentUser!
        let id = FSUtil.shared.getUID()!
        
        if segue.identifier == "goMoreFromLogin" {
            _ = segue.destination as! MoreInfoController
            let user = User(userID: id, name: currUser.displayName!, email: currUser.email!)
            FSUtil.shared.updateUser(user: user) { error in
                if let error = error {
                    print("Error updating user: \(error)")
                } else {
                    print("User updated successfully")
                }
            }
        }
        if segue.identifier == "goHomeFromLogin" {
            FSUtil.shared.getUser() { result in
                switch result {
                case .success(_):
                    print("Successfully got user")
                case .failure(let error):
                    print("Failed to get user: \(error)")
                }
            }
        }
    }
}
