//
//  LandingViewController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/6/23.
//

import UIKit
import Lottie
import FirebaseFirestore
import FirebaseAuthUI
import FirebaseEmailAuthUI
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI

class LandingController: BaseViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
        
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
        animationView.stop()
        present(authViewController, animated: true, completion: nil)
    }
}

extension BaseViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        // Check for error
        guard error == nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Check if the user has filled in their Vin already (meaning they are not signing up but logging in)
            if (UserManager.shared.getCurrentUser()?.vin != nil) {
                // User Document exists
                // User is logging in
                // Don't ask for more information and go to home page
                self.performSegue(withIdentifier: "goHomeFromLogin", sender: self)
            } else {
                // User Document does not exist
                // User is signing up
                // Transition to more page for more info
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
}
