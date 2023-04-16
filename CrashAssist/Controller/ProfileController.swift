//
//  ProfileController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit
import FirebaseStorage
import SDWebImage

class ProfileController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var birthdateText: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        // Add tap gesture recognizer to the profile image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true

        // Set up image picker
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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

                    // Download and display the profile image using SDWebImage
                    if let url = user.profileImageURL {
                        self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "account_default"))
                        }
                case .failure(let error):
                    print("Error fetching user: \(error)")
            }
        }
    }
    
    @objc func imageTapped() {
        // Show the image picker to select a photo
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the selected image
        guard let image = info[.editedImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        activityIndicator.startAnimating()
        FSUtil.shared.uploadProfileImage(image: image) { result in
            switch result {
            case .success(let downloadURL):
                print("Image uploaded successfully. Download URL: \(downloadURL)")
                self.activityIndicator.stopAnimating()
                // Update the UI with the new image
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
                // Show an error message to the user
            }
        }

        // Set the selected image as the profile image view's image
        profileImageView.image = image

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
