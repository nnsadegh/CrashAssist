//
//  TextFieldCell.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/30/23.
//

import UIKit

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = "FieldTableViewCell"
    
    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var field: UITextField!
    
    static func nib() -> UINib {
        return UINib(nibName: "FieldTableViewCell", bundle: nil)
    }
    
    public func configure(with fieldName: String){
        self.fieldName.text = fieldName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        field.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }

}
