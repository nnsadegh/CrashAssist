//
//  ViewController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 3/29/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreSwift

class BaseViewController: UIViewController {
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add tap gesture recognizer to dismiss keyboard when user taps outside of the text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Add spinner to the view
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.tag = 100
        
        // Set spinner properties
        spinner.hidesWhenStopped = true
        spinner.color = .gray
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func keyboardWillShow(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            adjustScrollViewInsets(contentInsets)
        }
        
        @objc func keyboardWillHide(_ notification: Notification) {
            let contentInsets = UIEdgeInsets.zero
            adjustScrollViewInsets(contentInsets)
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
        
        func adjustScrollViewInsets(_ contentInsets: UIEdgeInsets) {
            // Find all scroll views in the view hierarchy and adjust their content insets
            view.subviews.forEach { subview in
                if let scrollView = subview as? UIScrollView {
                    scrollView.contentInset = contentInsets
                    scrollView.scrollIndicatorInsets = contentInsets
                }
            }
        }
}

