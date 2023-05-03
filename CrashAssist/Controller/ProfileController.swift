import UIKit
import FirebaseStorage
import SDWebImage

class ProfileController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var birthdateText: UILabel!
    @IBOutlet weak var accidentCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the profile image view with rounded corners
        imagePicker.delegate = self
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0
        profileImageView.layer.masksToBounds = true
        // Add tap gesture for changing the profile picture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileController.handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start spinner while waiting for data to load
        self.spinner.startAnimating()
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
        
        accidentCountLabel.text = "Number of Accidents: \(LogManager.shared.numberOfLogs())"
        
        // Download and display the profile image using SDWebImage
        if let url = user.profileImageURL {
            self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "account_default"))  { (image, error, cacheType, url) in
                DispatchQueue.main.async {
                    // Stop spinner when image has stopped loading
                    self.spinner.stopAnimating()
                    if let error = error {
                        // handle error
                        print("Error loading image: \(error.localizedDescription)")
                        return
                    }
                }
            }
        } else {
            spinner.stopAnimating()
        }
    }
    
    /**
     Start Image Picker Controller when the image view is tapped
     */
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    /**
     Once an image is selected update the image view and upload it to Firestore
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = image
            self.uploadProfileImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Upload Profile Image to Firebase storage and store ID with user
     */
    func uploadProfileImage(image: UIImage) {
        // Upload the image to Firebase storage
        let storageRef = Storage.storage().reference().child("profileImages").child("\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            self.activityIndicator.startAnimating()
            // Attempt to put image in Firebase Storage
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        DispatchQueue.main.async {
                            guard let downloadURL = url else {
                                if let error = error {
                                    print("Error getting download URL: \(error.localizedDescription)")
                                }
                                return
                            }
                            // Successfully stored image in Firebase Storage
                            UserManager.shared.updateField(.profileImageURL, value: downloadURL) { error in
                                DispatchQueue.main.async {
                                    if let error {
                                        print("Failed to update field due to: \(error)")
                                    }
                                    // Successfully updated user with profile image URL
                                    self.spinner.stopAnimating()
                                    self.profileImageView.image = image
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
