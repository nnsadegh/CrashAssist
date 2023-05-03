//
//  HeaderTableViewCell.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/30/23.
//
import UIKit

/**
 A cell with a label in larger text to represent sections
 */
class HeaderTableViewCell: UITableViewCell {
    
    static let identifier = "HeaderTableViewCell"
    
    @IBOutlet weak var label: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "HeaderTableViewCell", bundle: nil)
    }
    
    public func configure(with headerName: String){
        label.text = headerName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
