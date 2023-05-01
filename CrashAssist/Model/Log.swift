//
//  Log.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct Log: Codable, Equatable {
    enum FieldKeys: String, CodingKey {
        case logID
        case userID
        case otherDriverName
        case otherDriverPhone
        case otherDriverAddress
        case otherDriverInsuranceCompany
        case otherDriverPolicyNumber
        case otherVehicleMake
        case otherVehicleModel
        case otherVehicleLicensePlate
        case otherVehicleMedia
        case location
        case locationString
        case time
        case yourVehicleMedia
        case policeReport
        case officerName
        case officerBadgeNumber
        case description
    }
    
    let logID: String
    let userID: String
    var otherDriverName: String?
    var otherDriverPhone: String?
    var otherDriverAddress: String?
    var otherDriverInsuranceCompany: String?
    var otherDriverPolicyNumber: String?
    var otherVehicleMake: String?
    var otherVehicleModel: String?
    var otherVehicleLicensePlate: String?
    var otherVehicleMedia: [String]?
    var witnesses: [String]?
    var location: GeoPoint
    var locationString: String
    var time: Date?
    var yourVehicleMedia: [String]?
    var policeReport: String?
    var officerName: String?
    var officerBadgeNumber: String?
    var description: String?
    
    init?(dictionary: [FieldKeys: Any]) {
        guard let uid = dictionary[.userID] as? String,
              let logid = dictionary[.logID] as? String else {
            return nil
        }
        logID = logid
        userID = uid
        otherDriverName = dictionary[.otherDriverName] as? String
        otherDriverPhone = dictionary[.otherDriverPhone] as? String
        otherDriverAddress = dictionary[.otherDriverAddress] as? String
        otherDriverInsuranceCompany = dictionary[.otherDriverInsuranceCompany] as? String
        otherDriverPolicyNumber = dictionary[.otherDriverPolicyNumber] as? String
        otherVehicleMake = dictionary[.otherVehicleMake] as? String
        otherVehicleModel = dictionary[.otherVehicleModel] as? String
        otherVehicleLicensePlate = dictionary[.otherVehicleLicensePlate] as? String
        location = dictionary[.location] as! GeoPoint
        locationString = dictionary[.locationString] as! String
        time = dictionary[.time] as? Date
        yourVehicleMedia = dictionary[.yourVehicleMedia] as? [String]
        otherVehicleMedia = dictionary[.otherVehicleMedia] as? [String]
        policeReport = dictionary[.policeReport] as? String
        officerName = dictionary[.officerName] as? String
        officerBadgeNumber = dictionary[.officerBadgeNumber] as? String
        description = dictionary[.description] as? String
    }
}
