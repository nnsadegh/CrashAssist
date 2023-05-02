//
//  User.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/8/23.
//

import Foundation

struct User : Codable {
    var uid: String
    var name: String?
    var email: String?
    var profileImageURL: URL?
    var birthdate: Date?
    var vin: String?
    
    /**
     Create a user object given an ID and user data in a dictionary using the enums from the UserManager class
     */
    init(userID: String, data: [UserManager.UserField: Any]) {
        uid = userID
        name = data[UserManager.UserField.name] as? String
        email = data[UserManager.UserField.email] as? String
        profileImageURL = URL(string: data[UserManager.UserField.profileImageURL] as? String ?? "")
        birthdate = data[UserManager.UserField.birthdate] as? Date
        vin = data[UserManager.UserField.vin] as? String
    }

}
