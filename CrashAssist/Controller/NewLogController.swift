//
//  NewReportController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit

class NewLogController: BaseViewController, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
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
    }
    
    @IBAction func saveDidTapped(_ sender: UIButton) {
        // TODO: Save data to Firestore
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        clearTextFields()
        self.dismiss(animated: true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
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
