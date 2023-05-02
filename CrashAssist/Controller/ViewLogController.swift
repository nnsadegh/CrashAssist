//
//  ViewLogController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/30/23.
//

import UIKit
import SwiftUI

class ViewLogController : BaseViewController {
    
    var receivedLog: Log?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBSegueAction func embedLogView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: LogView(selectedLog: receivedLog))
    }
    
}
