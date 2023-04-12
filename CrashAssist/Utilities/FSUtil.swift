//
//  FSUtil.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/8/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FSUtil {
    static let shared = FSUtil()
    private let db = Firestore.firestore()
    private let userCollectionRef = Firestore.firestore().collection("users")
    private let logCollectionRef = Firestore.firestore().collection("logs")
    private var id : String? {
        Auth.auth().currentUser?.uid
    }
    
    private init() {}
    
    func checkDocumentExists(documentId: String, collectionId: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection(collectionId).document(documentId).getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(false, error)
            } else if let document = documentSnapshot, document.exists {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func userExists(completion: @escaping (Bool) -> Void) {
        if let id {
            userCollectionRef.document(id).getDocument { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    completion(false)
                    return
                }

                if document.exists {
                    // Document exists
                    completion(true)
                } else {
                    // Document does not exist
                    completion(false)
                }
            }
        }
    }
    
    func updateUser(user: User, completion: @escaping (Error?) -> Void) {
        do {
            let userDocumentData = try Firestore.Encoder().encode(user)
            userCollectionRef.document(user.userID).setData(userDocumentData) { error in
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
    
    func getUser(completion: @escaping (Result<User, Error>) -> Void) {
        if let id {
            let userDocRef = userCollectionRef.document(id)
            userDocRef.getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let document = document, document.exists, let data = document.data() else {
                    let error = NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                    completion(.failure(error))
                    return
                }
                do {
                    let user = try Firestore.Decoder().decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getUID() -> String? {
        return id
    }
}
