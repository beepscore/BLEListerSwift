//
//  MasterViewController.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit
import os.log

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var bleDiscovery: BLEDiscovery? = nil

    override func viewDidLoad() {
        os_log("viewDidLoad", log: Logger.shared.log, type: .debug)

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        bleDiscovery = BLEDiscovery.shared
        registerForBleDiscoveryDidRefreshNotification()

        navigationItem.leftBarButtonItem = editButtonItem

        let scanButton = UIBarButtonItem(title: NSLocalizedString("Scan", comment: "Scan"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(safeScanForPeripherals(_:)))
        navigationItem.rightBarButtonItem = scanButton

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // TODO: change or delete this method, currently not used
//    func insertNewObject(_ sender: Any) {
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let discovery = self.bleDiscovery else {
            return
        }

        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.peripheral = discovery.foundPeripherals[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let discovery = self.bleDiscovery else {
            return 0
        }
        return discovery.foundPeripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        guard let discovery = self.bleDiscovery else {
            cell.textLabel!.text = "error bleDiscovery nil"
            return cell
        }
        cell.textLabel!.text = discovery.foundPeripherals[indexPath.row].name
        cell.detailTextLabel!.text = discovery.foundPeripherals[indexPath.row].identifier.uuidString
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if bleDiscovery?.foundPeripherals == nil {
            return
        }

        if editingStyle == .delete {
            // remove from model object, not from a copy
            //bleDiscovery!.foundPeripherals!.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: -

    @objc func safeScanForPeripherals(_ sender: Any) {
        guard let discovery = self.bleDiscovery else {
            return
        }
        discovery.safeScanForPeripherals()
    }

    // MARK: - Register for notifications

    func registerForBleDiscoveryDidRefreshNotification() {
        guard let nc = bleDiscovery?.notificationCenter else { return }

        nc.addObserver(self,
                       selector:#selector(discoveryDidRefreshWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didRefresh.rawValue),
                       object:nil)
    }

    // MARK: - Notification handlers

    @objc func discoveryDidRefreshWithNotification(_ notification: NSNotification) {
        os_log("MasterViewController discoveryDidRefreshWithNotification",
               log: Logger.shared.log,
               type: .debug)

        if notification.userInfo != nil {
            os_log("notification.userInfo: %@",
                   log: Logger.shared.log,
                   type: .debug,
                   String(describing:notification.userInfo))
        }
        tableView.reloadData()
    }

}

