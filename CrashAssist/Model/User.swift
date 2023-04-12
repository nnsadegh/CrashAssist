//
//  User.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/8/23.
//

import Foundation

struct User : Encodable, Decodable {
    var userID: String
    var name: String?
    var email: String?
    var profileImageURL: URL?
    var birthdate: Date?
    var vin: String?
}
