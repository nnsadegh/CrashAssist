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
        imagePicker.delegate = self
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileController.handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let user = UserManager.shared.getCurrentUser()!
        // Do something with the user object
        nameText.text = user.name
        emailText.text = user.email!
        
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
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = image
            self.uploadProfileImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileImage(image: UIImage) {
        // Upload the image to Firebase storage
        let storageRef = Storage.storage().reference().child("profileImages").child("\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            self.activityIndicator.startAnimating()
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                // Update the image view with the newly uploaded image
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                        }
                        return
                    }
                    self.spinner.startAnimating()
                    UserManager.shared.updateField(.profileImageURL, value: downloadURL) { error in
                        if let error {
                            print("Failed to update field due to: \(error)")
                        }
                        self.spinner.stopAnimating()
                    }
                    self.profileImageView.sd_setImage(with: downloadURL, placeholderImage: UIImage(named: "account_default"))
                }
            }
        }
    }
}
