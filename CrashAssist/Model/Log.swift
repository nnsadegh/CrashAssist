//
//  Log.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import Foundation

struct Log : Codable, Equatable {
    public let logID: String
    public let userID: String
    
    public var otherDriverName: String?
    public var otherDriverPhone: String?
    public var otherDriverAddress: String?
    public var otherDriverInsuranceCompany: String?
    public var otherDriverPolicyNumber: String?
    public var otherVehicleMake: String?
    public var otherVehicleModel: String?
    public var otherVehicleLicensePlate: String?
    
    public var otherVehicleMedia: [String]?
    public var witnesses: [String]?
    public var location: String?
    public var time: Date?
    public var yourVehicleMedia: [String]?
    public var policeReport: String?
    public var officerName: String?
    public var officerBadgeNumber: String?
    public var description: String?
    
    init?(dictionary: [String: Any]) {
        guard let uid = dictionary["userID"] as? String, let logid = dictionary["logID"] as? String else {
            return nil
        }
        logID = logid
        userID = uid
        otherDriverName = dictionary["otherDriverName"] as? String
        otherDriverPhone = dictionary["otherDriverPhone"] as? String
        otherDriverAddress = dictionary["otherDriverAddress"] as? String
        otherDriverInsuranceCompany = dictionary["otherDriverInsuranceCompany"] as? String
        otherDriverPolicyNumber = dictionary["otherDriverPolicyNumber"] as? String
        otherVehicleMake = dictionary["otherVehicleMake"] as? String
        otherVehicleModel = dictionary["otherVehicleModel"] as? String
        otherVehicleLicensePlate = dictionary["otherVehicleLicensePlate"] as? String
        witnesses = dictionary["witnesses"] as? [String]
        location = dictionary["location"] as? String
        time = dictionary["time"] as? Date
        yourVehicleMedia = dictionary["yourVehicleMedia"] as? [String]
        otherVehicleMedia = dictionary["otherVehicleMedia"] as? [String]
        policeReport = dictionary["policeReport"] as? String
        officerName = dictionary["officerName"] as? String
        officerBadgeNumber = dictionary["officerBadgeNumber"] as? String
        description = dictionary["description"] as? String
    }
}
