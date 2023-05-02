//
//  NewLogControllerV2.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/26/23.
//

import Foundation
import UIKit

class NewLogControllerV2: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Fields for log creation page with string values
    let otherDriverFields = ["Driver's Name", "Phone Number", "Address", "Insurance Company", "Policy Number", "Vehicle Make", "Vehicle Model", "License Plate #"]
    let miscellaneousFields = ["Police Report #", "Office Name", "Officer Badge Number"]
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        
        table.register(HeaderTableViewCell.nib(), forCellReuseIdentifier: HeaderTableViewCell.identifier)
        table.register(FieldTableViewCell.nib(), forCellReuseIdentifier: FieldTableViewCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    /**
     Configure each table view cell with this function
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.identifier, for: indexPath) as! HeaderTableViewCell
            cell.configure(with: "Other Driver Information")
            return cell
        case 1...8:
            let cell = tableView.dequeueReusableCell(withIdentifier: FieldTableViewCell.identifier, for: indexPath) as! FieldTableViewCell
            cell.configure(with: otherDriverFields[indexPath.row-1])
            return cell
//        case 9:
//            // TODO: Create Location Cell
//        case 10:
//            // TODO: Create Time Picking Cell
//        case 11...13:
//            let cell = tableView.dequeueReusableCell(withIdentifier: FieldTableViewCell.identifier, for: indexPath) as! FieldTableViewCell
//            cell.configure(with: miscellaneousFields[indexPath.row-10])
//        case 14:
//            // TODO: Create Text View Cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.identifier, for: indexPath) as! HeaderTableViewCell
            cell.configure(with: "")
            return cell
        }
    }
}
