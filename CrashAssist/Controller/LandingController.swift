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
//          FUIGoogleAuth(authUI: FUIAuth.defaultAuthUI()!),
//          FUIFacebookAuth(authUI: FUIAuth.defaultAuthUI()!),
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
        let currUser = Auth.auth().currentUser!
        let id = currUser.uid
        let userCollectionRef = Firestore.firestore().collection("users")
        let documentId = userCollectionRef.document().documentID
        userCollectionRef.document(id).setData([
            "id": id,
            "name": currUser.displayName!,
            "email": currUser.email!,
            "isVerified": currUser.isEmailVerified,
        ])
        
        // Transition to home
        performSegue(withIdentifier: "goHome", sender: self)
    }
    
}
