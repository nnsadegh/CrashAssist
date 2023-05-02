//
//  UserManager.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/18/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager {
    
    static let shared = UserManager()
    
    let userCollectionRef = Firestore.firestore().collection("users")
    
    private var currentUser: User?
    private var currentUserRef: DocumentReference?
    
    enum UserError: Error {
        case notLoggedIn
    }
    
    enum UserField: String {
        case name
        case email
        case birthdate
        case profileImageURL
        case vin
    }
    
    private init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else {
                self.currentUser = nil
                return
            }
            
            self.currentUserRef = self.userCollectionRef.document(user.uid)
            self.currentUserRef?.addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching user document: \(error)")
                    self.currentUser = nil
                    return
                }
                guard let data = snapshot?.data() else {
                    self.currentUser = nil
                    return
                }
                do {
                    self.currentUser = try Firestore.Decoder().decode(User.self, from: data)
                } catch let decodingError {
                    print("Error decoding user: \(decodingError)")
                    self.currentUser = nil
                }
            }
        }
    }
    
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func updateField(_ field: UserField, value: Any, completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(UserError.notLoggedIn)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        var updateData: [String: Any] = [:]
        
        if field == .profileImageURL, let url = value as? NSURL {
            updateData[field.rawValue] = url.absoluteString
        } else {
            updateData[field.rawValue] = value
        }
        
        userRef.updateData(updateData) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateData(_ data: [UserField: Any], completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(UserError.notLoggedIn)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        var updatedData = [String: Any]()
        for (key, value) in data {
            updatedData[key.rawValue] = value
        }
        
        userRef.updateData(updatedData) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func userLoggedIn(onComplete: @escaping (Bool) -> Void) {
        let isLoggedIn = Auth.auth().currentUser != nil
        onComplete(isLoggedIn)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print("Error signing out: %@", error)
        }
        currentUser = nil
        currentUserRef = nil
    }
    
    func updateUser(user: User, completion: @escaping (Error?) -> Void) {
        currentUser = user
        do {
            let userDocumentData = try Firestore.Encoder().encode(user)
            userCollectionRef.document(user.uid).updateData(userDocumentData) { error in
                if let error = error {
                    print("Error updating user: \(error)")
                    completion(error)
                } else {
                    print("User updated successfully")
                    completion(nil)
                }
            }
        } catch let encodingError {
            print("Error encoding user: \(encodingError)")
            completion(encodingError)
        }
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(UserError.notLoggedIn)
            return
        }
        
        // Delete the user document in Firestore
        userCollectionRef.document(currentUser.uid).delete { error in
            if let error = error {
                print("Error deleting user document: \(error)")
                completion(error)
                return
            }
            
            // Delete the user locally
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                print("Error signing out: %@", error)
                completion(error)
                return
            }
            
            self.currentUser = nil
            self.currentUserRef = nil
            
            completion(nil)
        }
    }

}
