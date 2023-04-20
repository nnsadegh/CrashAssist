//
//  User.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/8/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User : Codable {
    var uid: String
    var name: String?
    var email: String?
    var profileImageURL: URL?
    var birthdate: Date?
    var vin: String?
    
    init(userID: String, data: [UserManager.UserField: Any]) {
        uid = userID
        name = data[UserManager.UserField.name] as? String
        email = data[UserManager.UserField.email] as? String
        profileImageURL = URL(string: data[UserManager.UserField.profileImageURL] as? String ?? "")
        
        if let birthdateTimestamp = data[UserManager.UserField.birthdate] as? Timestamp {
            birthdate = birthdateTimestamp.dateValue()
        }
        
        vin = data[UserManager.UserField.vin] as? String
    }

}
