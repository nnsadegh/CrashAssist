//
//  LogModel.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class LogManager {
    // Singleton instance
    static let shared = LogManager()
    
    // Array of logs
    private var logs: [Log] = []
    
    // Private initializer to prevent instantiation outside the class
    private init() {}
    
    func numberOfLogs() -> Int {
        return logs.count
    }
    
    // Returns log at index
    func log(at index: Int) -> Log? {
        if !outOfBounds(at: index) {
            return logs[index]
        } else {
            return nil
        }
    }
    
    // Add a log to the array
    func addLog(log: Log) {
        logs.append(log)
        
        // Upload log to Firestore
        do {
            let data = try Firestore.Encoder().encode(log)
            
            Firestore.firestore().collection("logs").document(log.logID).setData(data) { error in
                if let error = error {
                    print("Error saving log: \(error.localizedDescription)")
                } else {
                    print("Log saved successfully")
                }
            }
        } catch {
            print("Error encoding log: \(error.localizedDescription)")
        }
    }
    
    // Grabs user logs from Firebase
    func updateLogsFromFirestore(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        guard let userId = UserManager.shared.getCurrentUser()?.uid else {
            print("Error could not get User ID to update logs")
            return
        }
        
        db.collection("logs").whereField(Log.FieldKeys.userID.rawValue, isEqualTo: userId).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching logs: \(error?.localizedDescription ?? "unknown error")")
                completion()
                return
            }
            
            self.logs = []
            
            for document in snapshot.documents {
                let logData = document.data()
                do {
                    let log = try Firestore.Decoder().decode(Log.self, from: logData)
                    self.logs.append(log)
                } catch let error {
                    print("Error decoding log: \(error.localizedDescription)")
                }
            }
            completion()
        }
    }
    
    // Remove log from database
    func removeLog(atIndex index: Int) {
        if outOfBounds(at: index) {return}
        
        let logToRemove = logs[index]
        
        // Remove the log from Firestore
        let db = Firestore.firestore()
        let logsCollectionRef = db.collection("logs")
        logsCollectionRef.document(logToRemove.logID).delete { error in
            if let error = error {
                print("Error deleting log: \(error.localizedDescription)")
            } else {
                print("Log successfully deleted from Firestore")
                self.logs.remove(at: index)
            }
        }
    }
    
    func rearrangeLogs(from: Int, to: Int) {
        if !outOfBounds(at: from) && !outOfBounds(at: to) {
            let log = logs.remove(at: from)
            logs.insert(log, at: to)
        }
    }
    
    func deleteAllLogs(completion: @escaping () -> Void) {
        // Remove logs from Firestore
        let db = Firestore.firestore()
        let logsCollectionRef = db.collection("logs")
        let userId = UserManager.shared.getCurrentUser()?.uid ?? ""
        logsCollectionRef.whereField(Log.FieldKeys.userID.rawValue, isEqualTo: userId).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching logs to delete: \(error?.localizedDescription ?? "unknown error")")
                completion()
                return
            }

            let batch = db.batch()

            for document in snapshot.documents {
                batch.deleteDocument(logsCollectionRef.document(document.documentID))
            }

            batch.commit { error in
                if let error = error {
                    print("Error deleting logs from Firestore: \(error.localizedDescription)")
                } else {
                    print("Logs successfully deleted from Firestore")
                    self.logs.removeAll()
                }
                completion()
            }
        }
    }
    
    // Checks for out of bounds array calls
    private func outOfBounds(at index: Int) -> Bool {
        if index >= 0, index <= logs.count {
            return false
        } else {
            return true
        }
    }
}
