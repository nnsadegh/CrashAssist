//
//  NewReportController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit
import FirebaseFirestore

class NewLogController: BaseViewController, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var driverName: UITextField!
    @IBOutlet weak var driverPhoneNumber: UITextField!
    @IBOutlet weak var driverAddress: UITextField!
    @IBOutlet weak var driverInsurance: UITextField!
    @IBOutlet weak var driverPolicyNumber: UITextField!
    @IBOutlet weak var driverVehicleMake: UITextField!
    @IBOutlet weak var driverVehicleModel: UITextField!
    @IBOutlet weak var driverLicensePlate: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        saveButton.isEnabled = false
        
        driverName.delegate = self
        driverPhoneNumber.delegate = self
        driverAddress.delegate = self
        driverInsurance.delegate = self
        driverPolicyNumber.delegate = self
        driverVehicleMake.delegate = self
        driverVehicleModel.delegate = self
        driverLicensePlate.delegate = self
    }
    
    @IBAction func saveDidTapped(_ sender: UIButton) {
        // TODO: Save data to Firestore
        let newLogRef = Firestore.firestore().collection("logs").document()
        let logDictionary: [Log.FieldKeys: Any] = [
            .userID: UserManager.shared.getCurrentUser()?.uid ?? "",
            .logID: newLogRef.documentID,
            .otherDriverName: driverName.text ?? "",
            .otherDriverPhone: driverPhoneNumber.text ?? "",
            .otherDriverAddress: driverAddress.text ?? "",
            .otherDriverInsuranceCompany: driverInsurance.text ?? "",
            .otherDriverPolicyNumber: driverPolicyNumber.text ?? "",
            .otherVehicleMake: driverVehicleMake.text ?? "",
            .otherVehicleModel: driverVehicleModel.text ?? "",
            .otherVehicleLicensePlate: driverLicensePlate.text ?? "",
//            .location: "",
//            .time: Date(),
//            .witnesses: [],
//            .yourVehicleMedia: [],
//            .otherVehicleMedia: [],
//            .policeReport: "",
//            .officerName: "",
//            .officerBadgeNumber: "",
//            .description: ""
        ]
        
        // Try to create a Log object from the dictionary
        guard let log = Log(dictionary: logDictionary) else {
            print("Error creating Log object from dictionary")
            return
        }
        
        do {
            let data = try Firestore.Encoder().encode(log)
            
            Firestore.firestore().collection("logs").document(log.logID).setData(data) { error in
                if let error = error {
                    print("Error saving log: \(error.localizedDescription)")
                } else {
                    print("Log saved successfully")
                }
            }
        } catch {
            print("Error encoding log: \(error.localizedDescription)")
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        clearTextFields()
        self.dismiss(animated: true)
    }
    
    internal func textFieldDidChangeSelection(_ textField: UITextField) {
        enableOrDisableButton()
    }

    func enableOrDisableButton() {
        // Enable or disable the "Save" button base on the inputs
        saveButton.isEnabled = requiredFieldsNotEmpty()
    }
    
    /**
     Checks if required fields for log are empty or not
     */
    func requiredFieldsNotEmpty() -> Bool {
        if driverName.text?.isEmpty ?? true ||
            driverPhoneNumber.text?.isEmpty ?? true ||
            driverAddress.text?.isEmpty ?? true ||
            driverInsurance.text?.isEmpty ?? true ||
            driverPolicyNumber.text?.isEmpty ?? true ||
            driverVehicleMake.text?.isEmpty ?? true ||
            driverVehicleModel.text?.isEmpty ?? true ||
            driverLicensePlate.text?.isEmpty ?? true {
            return false
        }
        return true
    }
    
    /**
        Clears the text fields upon saving or exiting from this page
     */
    func clearTextFields() {
        driverName.text = ""
        driverPhoneNumber.text = ""
        driverAddress.text = ""
        driverInsurance.text = ""
        driverPolicyNumber.text = ""
        driverVehicleMake.text = ""
        driverVehicleModel.text = ""
        driverLicensePlate.text = ""
    }
}
