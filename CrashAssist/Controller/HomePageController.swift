//
//  HomePageController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit
import Lottie

class HomePageController: BaseViewController, UITableViewDataSource {
    
    fileprivate var selectedLog : Log?
    
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var emptyLogsAnimationView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cellTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        cellTap.addTarget(self, action: #selector(handleCellTap(_:)))
        
        // Setup animation views
        emptyLogsAnimationView.contentMode = .scaleAspectFit
        emptyLogsAnimationView.loopMode = .playOnce
        emptyLogsAnimationView.animationSpeed = 0.5
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 0.5
        
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        emptyLogsAnimationView.isHidden = true
        loadingAnimationView.isHidden = false
        
        // Play Loading Animation
        loadingAnimationView.play()
        loadingAnimationView.isHidden = false

        // Get new logs
        LogManager.shared.updateLogsFromFirestore() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.loadingAnimationView.stop()
                self.loadingAnimationView.isHidden = true
                // Display appropriate elements
                if LogManager.shared.numberOfLogs() == 0 {
                    // Show Empty Logs Animation and Label
                    self.emptyLogsAnimationView.isHidden = false
                    self.emptyLogsAnimationView.play()
                } else {
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LogManager.shared.numberOfLogs()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell")!
        var content = cell.defaultContentConfiguration()

        let log = LogManager.shared.log(at: indexPath.row)
        content.text = log?.time?.formatted()
        content.secondaryText = log?.locationString
        cell.contentConfiguration = content
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        LogManager.shared.rearrangeLogs(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    @IBAction func editButtonDidTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Edit" {
            sender.title = "Done"
            tableView.isEditing = true
        } else {
            sender.title = "Edit"
            tableView.isEditing = false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            // Remove the quote from the LogManager
            LogManager.shared.removeLog(atIndex: indexPath.row)

            // Remove the cell from the tableview
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLog = LogManager.shared.log(at: indexPath.row)
        performSegue(withIdentifier: "ViewLogSegue", sender: self)
    }

    @objc func handleCellTap(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let cell = sender.view as? UITableViewCell {
                    selectedLog = LogManager.shared.log(at: tapIndexPath.row)
                    performSegue(withIdentifier: "ViewLogSegue", sender: cell)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewLogSegue" {
            if let destinationVC = segue.destination as? ViewLogController {
                destinationVC.receivedLog = self.selectedLog
            }
        }
    }

}
