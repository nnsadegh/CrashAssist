//
//  TestView.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/30/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

struct LogView: View {
    var selectedLog: Log!
    var fieldNA = "Field N/A"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Display other driver details
                Text("Other Driver Details").font(.title)
                
                Group {
                    KeyValueRow(key: "Other Driver Name", value: selectedLog.otherDriverName ?? fieldNA)
                    KeyValueRow(key: "Other Driver Phone", value: selectedLog.otherDriverPhone ?? fieldNA)
                    KeyValueRow(key: "Other Driver Address", value: selectedLog.otherDriverAddress ?? fieldNA)
                    KeyValueRow(key: "Other Driver Insurance Company", value: selectedLog.otherDriverInsuranceCompany ?? fieldNA)
                    KeyValueRow(key: "Other Driver Policy Number", value: selectedLog.otherDriverPolicyNumber ?? fieldNA)
                    KeyValueRow(key: "Other Vehicle Make", value: selectedLog.otherVehicleMake ?? fieldNA)
                    KeyValueRow(key: "Other Vehicle Model", value: selectedLog.otherVehicleModel ?? fieldNA)
                    KeyValueRow(key: "Other Vehicle License Plate", value: selectedLog.otherVehicleLicensePlate ?? fieldNA)
                }
                Text("Your Details").font(.title)
                // Display map view
                Text("Accident Location").font(.title3.bold())
                if let location = getLocationFromLog(selectedLog) {
                    MapView(centerCoordinate: location.coordinate)
                        .frame(height: 300)
                        .cornerRadius(10)
                }
                Text(selectedLog.locationString)
                Divider()
                // Display your details with string values
                Group {
                    KeyValueRow(key: "Time", value: formatDate(selectedLog.time))
                    KeyValueRow(key: "Police Report", value: selectedLog.policeReport ?? fieldNA)
                    KeyValueRow(key: "Officer Name", value: selectedLog.officerName ?? fieldNA)
                    KeyValueRow(key: "Officer Badge Number", value: selectedLog.officerBadgeNumber ?? fieldNA)
                    KeyValueRow(key: "Description", value: selectedLog.description ?? fieldNA)
                }
            }.padding()
        }
    }
    
    /**
     Convert geopoint into a CLLocation object for map display
     */
    func getLocationFromLog(_ log: Log) -> CLLocation? {
        let latitude = log.location.latitude
        let longitude = log.location.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /**
     Format date object from log into a string object
     */
    func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        return dateFormatter.string(from: date)
    }
}

/**
 Create MapView from MapKit that shows the location for the log being viewed
 */
struct MapView: UIViewRepresentable {
    var centerCoordinate: CLLocationCoordinate2D

    /**
     Create map view element
     */
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isScrollEnabled = false
        return mapView
    }

    /**
     Updated map view element with proper data and frame
     */
    func updateUIView(_ view: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate

        view.removeAnnotations(view.annotations)
        view.setRegion(region, animated: true)
        view.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /**
     Define pin annotation for map view
     */
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView.canShowCallout = true
            return annotationView
        }
    }
}

/**
 The following code represents the Key Value pairs in the view where the values are strings
 */
struct KeyValueRow: View {
    let key: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(key)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.5)
                .lineLimit(nil).font(.title3.bold())
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.5)
                .lineLimit(nil)
            Divider()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        // Create dummy data for preview
        let dictionary: [Log.FieldKeys: Any] = [
            .logID: "123456789",
            .userID: "987654321",
            .otherDriverName: "John Doe",
            .otherDriverPhone: "555-555-5555",
            .otherDriverAddress: "123 Main St",
            .otherDriverInsuranceCompany: "State Farm",
            .otherDriverPolicyNumber: "ABCD1234",
            .otherVehicleMake: "Toyota",
            .otherVehicleModel: "Camry",
            .otherVehicleLicensePlate: "ABC123",
            .location: GeoPoint(latitude: 37.7749, longitude: -122.4194),
            .locationString: "San Francisco, CA",
            .time: Date(),
            .yourVehicleMedia: ["https://example.com/image.jpg"],
            .otherVehicleMedia: ["https://example.com/image.jpg"],
            .policeReport: "1234",
            .officerName: "Officer Smith",
            .officerBadgeNumber: "1234",
            .description: "Accident occurred at the intersection of Main St and Elm St."
        ]

        if let log = Log(dictionary: dictionary) {
            LogView(selectedLog: log)
        }
    }
}
