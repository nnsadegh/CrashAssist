//
//  LoadingScreenController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 5/1/23.
//


import UIKit
import Lottie
import FirebaseFirestore

class LoadingScreenController: BaseViewController {
    
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Setup Animation View
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .playOnce
        loadingAnimationView.animationSpeed = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingAnimationView.play()
        UserManager.shared.userLoggedIn() { isLoggedIn in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.loadingAnimationView.stop()
                if isLoggedIn {
                    self.performSegue(withIdentifier: "goHomeFromLoading", sender: self)
                } else {
                    print("User is not logged in")
                    self.performSegue(withIdentifier: "goLandingFromLoading", sender: self)
                }
            }
        }
    }
}
