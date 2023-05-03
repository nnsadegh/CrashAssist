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
    
    // Enums for User Fields
    enum UserField: String {
        case name
        case email
        case birthdate
        case profileImageURL
        case vin
    }
    
    /**
     Initializer for singleton class of UserManager
     */
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
    
    /**
     Gets the current user as a User object
     */
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    /**
     Updates a specific field of the user object locally and in Firestore given the UserField enum and its value
     */
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
    
    /**
     Updates multiple pieces of data in the user object and in Firestore given a data dictionary
     */
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
    
    /**
     Update the user with a User object given as a parameter, if the user doesn't exist, create a document for it
     */
    func updateUser(user: User, completion: @escaping (Error?) -> Void) {
        currentUser = user
        do {
            let userDocumentData = try Firestore.Encoder().encode(user)
            userCollectionRef.document(user.uid).setData(userDocumentData) { error in
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
    
    /**
     Check if the user is logged in
     */
    func userLoggedIn(onComplete: @escaping (Bool) -> Void) {
        let isLoggedIn = Auth.auth().currentUser != nil
        onComplete(isLoggedIn)
    }
    
    /**
     Sign the user out and clear data accordingly
     */
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print("Error signing out: %@", error)
        }
        currentUser = nil
        currentUserRef = nil
    }
    
    /**
     Delete user locally and from Firebase and clear data accordingly
     */
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
            
            // Delete user in Firestore Auth
            Auth.auth().currentUser?.delete() { error in
                if let error {completion(error)}
                // Delete the user locally
                self.currentUser = nil
                self.currentUserRef = nil
                
                completion(nil)
                
            }
        }
    }

}
