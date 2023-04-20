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
        if UserManager.shared.userLoggedIn() {
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
        
        if (UserManager.shared.getCurrentUser()?.vin != nil) {
            // User Document exists
            // Don't ask for more information
            self.performSegue(withIdentifier: "goHomeFromLogin", sender: self)
        } else {
            // User Document does not exist
            // Transition to more page
            let currUser = Auth.auth().currentUser!
            let data: [UserManager.UserField: Any] = [
                UserManager.UserField.name: currUser.displayName!,
                UserManager.UserField.email: currUser.email!
            ]
            let user: User = User(userID: currUser.uid, data: data)
            UserManager.shared.updateUser(user: user) { error in
                if let error = error {
                    // Handle the error
                    print("Error updating user data: \(error)")
                } else {
                    self.performSegue(withIdentifier: "goMoreFromLogin", sender: self)
                }
            }
        }
    }
}
