//
//  NewReportController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreLocationUI
import FirebaseFirestore
import GoogleMaps
import GooglePlaces

class NewLogController: BaseViewController, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    // MARK: Other Driver Fields
    @IBOutlet weak var driverName: UITextField!
    @IBOutlet weak var driverPhoneNumber: UITextField!
    @IBOutlet weak var driverAddress: UITextField!
    @IBOutlet weak var driverInsurance: UITextField!
    @IBOutlet weak var driverPolicyNumber: UITextField!
    @IBOutlet weak var driverVehicleMake: UITextField!
    @IBOutlet weak var driverVehicleModel: UITextField!
    @IBOutlet weak var driverLicensePlate: UITextField!
    // MARK: Miscellaneous Fields
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var policeReportNumber: UITextField!
    @IBOutlet weak var officerName: UITextField!
    @IBOutlet weak var officerBadgeNumber: UITextField!
    @IBOutlet weak var notes: UITextView!
    
    let manager = CLLocationManager()
    let autocompleteController = GMSAutocompleteViewController()
    let geocoder = CLGeocoder()
    var selectedLocation: CLLocationCoordinate2D?
    var address: String?
    
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
        policeReportNumber.delegate = self
        officerName.delegate = self
        officerBadgeNumber.delegate = self
        notes.delegate = self
        autocompleteController.delegate = self
        mapView.delegate = self
        manager.delegate = self
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the latitude and longitude of the selected place
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        
        updateMap(latitude: latitude, longitude: longitude)
        
        // Update the text field with the selected address
        locationTextField.text = place.formattedAddress
        address = place.formattedAddress
        
        geocoder.geocodeAddressString(address!) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let location = placemark.location?.coordinate else {
                // Handle the error
                return
            }
            // Store the selected location
            self.selectedLocation = location
            print("Latitude: \(location.latitude), Longitude: \(location.longitude)")
        }
        
        // Check if all fields have been satisfied
        enableOrDisableButton()
        
        // Dismiss the autocomplete view controller
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Autocomplete error: \(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mapViewDidTapped(_ sender: UITapGestureRecognizer) {
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func editingBeganLocationTextField(_ sender: UITextField) {
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func saveDidTapped(_ sender: UIButton) {
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
            .location: selectedLocation != nil ? GeoPoint(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude) : "",
            .locationString: address ?? "Location not Entered",
            .time: timePicker.date,
            .yourVehicleMedia: [URL](),
            .otherVehicleMedia: [URL](),
            .policeReport: policeReportNumber.text  ?? "",
            .officerName: officerName.text  ?? "",
            .officerBadgeNumber: officerBadgeNumber.text ?? "",
            .description: notes.text ?? ""
        ]
        
        // Try to create a Log object from the dictionary
        guard let log = Log(dictionary: logDictionary) else {
            print("Error creating Log object from dictionary")
            return
        }
        
        LogManager.shared.addLog(log: log)
        presentingViewController?.viewWillAppear(true)
        self.dismiss(animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        self.manager.stopUpdatingLocation()
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
        locationTextField.text = location.description
    }
    
    @objc func getCurrentLocation() {
        manager.requestLocation()
    }
    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        clearTextFields()
        self.dismiss(animated: true)
    }
    
    internal func textFieldDidChangeSelection(_ textField: UITextField) {
        enableOrDisableButton()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != locationTextField { return }
        guard let address = textField.text else {
            return
        }
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let location = placemark.location?.coordinate else {
                // Handle the error
                return
            }
            // Store the selected location
            self.selectedLocation = location
            print("Latitude: \(location.latitude), Longitude: \(location.longitude)")
        }
    }

    func enableOrDisableButton() {
        // Enable or disable the "Save" button base on the inputs
        saveButton.isEnabled = requiredFieldsNotEmpty()
    }
    
    // Map view delegate method to customize the appearance of an annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
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
            driverLicensePlate.text?.isEmpty ?? true ||
            locationTextField.text?.isEmpty ?? true
        {
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
        policeReportNumber.text = ""
        officerName.text = ""
        officerBadgeNumber.text = ""
        notes.text = ""
    }
    
    func updateMap(latitude: Double, longitude: Double) {
        // Create a location for the map view to center on
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Set the map view's region to center on the initial location
        let regionRadius: CLLocationDistance = 1000 // in meters
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Add an annotation to the map view
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation.coordinate
        annotation.title = "Accident Location"
        mapView.addAnnotation(annotation)
    }
}
