//
//  HomePageController.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 4/7/23.
//

import UIKit

class HomePageController: BaseViewController, UITableViewDataSource {
    
    fileprivate var selectedLog : Log?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cellTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cellTap.addTarget(self, action: #selector(handleCellTap(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LogManager.shared.updateLogsFromFirestore() {
            self.tableView.reloadData()
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
