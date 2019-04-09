//
//  DetailViewController.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit
import CoreBluetooth
import os.log

class DetailViewController: UIViewController {

    var bleDiscovery: BLEDiscovery?
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!

    @IBOutlet weak var connectButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bleDiscovery = BLEDiscovery.shared
        registerForBleDiscoveryDidConnectPeripheralNotification()
        registerForBleDiscoveryDidDisconnectPeripheralNotification()
        registerForBleDiscoveryDidDiscoverServicesNotification()

        configureView()

        // TODO: scan for services, show them
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: CBPeripheral? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    /// Update the user interface for the detail item
    func configureView() {
        if let peripheral = detailItem {
            title = peripheral.name
            if let label = detailDescriptionLabel {
                label.text = peripheral.services.debugDescription
            }
            if let identifierLabel = identifierLabel {
                identifierLabel.text = peripheral.identifier.debugDescription
            }
            if let connectButton = connectButton {
                let buttonTitle = connectLabelTextForState(peripheral.state)
                connectButton.setTitle(buttonTitle, for: .normal)
            }
        }
    }

    func connectLabelTextForState(_ state: CBPeripheralState) -> String {
        var connectLabelText = ""
        switch (state) {

        case .disconnected:
            connectLabelText = "Connect"
        case .connecting:
            connectLabelText = ""
        case .connected:
            connectLabelText = "Disconnect"
        default:
            connectLabelText = ""
        }

        return connectLabelText;
    }

    // MARK: - Connect / Disconnect

    @IBAction func connectTapped(sender: Any) {
        guard let discovery = bleDiscovery, let peripheral = detailItem else { return }
        if detailItem?.state == .disconnected {
            connect(discovery: discovery, peripheral: peripheral)
        } else if detailItem?.state == .connected {
            disconnect(discovery: discovery, peripheral: peripheral);
        }
        // update UI based on detailItem state
        configureView();
    }

    func connect(discovery: BLEDiscovery, peripheral: CBPeripheral) {
        discovery.connectPeripheral(peripheral: peripheral)
    }

    func disconnect(discovery: BLEDiscovery, peripheral: CBPeripheral) {
        discovery.disconnectPeripheral(peripheral: peripheral)
    }

    // MARK: - Register for notifications

    func registerForBleDiscoveryDidConnectPeripheralNotification() {
        guard let nc = bleDiscovery?.notificationCenter else {
            return
        }

        nc.addObserver(self,
                       selector:#selector(discoveryDidConnectPeripheralWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didConnectPeripheral.rawValue),
                       object:nil)
    }

    func registerForBleDiscoveryDidDisconnectPeripheralNotification() {
        guard let nc = bleDiscovery?.notificationCenter else {
            return
        }

        nc.addObserver(self,
                       selector:#selector(discoveryDidDisconnectPeripheralWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didDisconnectPeripheral.rawValue),
                       object:nil)
    }

    func registerForBleDiscoveryDidDiscoverServicesNotification() {
        guard let nc = bleDiscovery?.notificationCenter else {
            return
        }

        nc.addObserver(self,
                       selector:#selector(discoveryDidDiscoverServicesWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didDiscoverServices.rawValue),
                       object:nil)
    }

    // MARK: - Notification response methods

    @objc func discoveryDidConnectPeripheralWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidConnectPeripheralWithNotification",
               log: Logger.shared.log,
               type: .debug)
        os_log("notification.object: %@",
               log: Logger.shared.log,
               type: .debug,
               String(describing: notification.object))

        if notification.userInfo != nil {
            if ((notification.userInfo?["peripheral"]) != nil) {
                os_log("notification.userInfo: %@",
                       log: Logger.shared.log,
                       type: .debug,
                       String(describing:notification.userInfo))
                configureView()
            }
        }
    }

    @objc func discoveryDidDisconnectPeripheralWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidDisconnectPeripheralWithNotification",
               log: Logger.shared.log,
               type: .debug)
        os_log("notification.object: %@",
               log: Logger.shared.log,
               type: .debug,
               String(describing: notification.object))

        if notification.userInfo != nil {
            if ((notification.userInfo?["peripheral"]) != nil) {
                os_log("notification.userInfo: %@",
                       log: Logger.shared.log,
                       type: .debug,
                       String(describing:notification.userInfo))
                configureView()
            }
        }
    }

    @objc func discoveryDidDiscoverServicesWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidDiscoverServicesWithNotification",
               log: Logger.shared.log,
               type: .debug)
        os_log("notification.object: %@",
               log: Logger.shared.log,
               type: .debug,
               String(describing: notification.object))

        if ((notification.userInfo?["peripheral"]) != nil) {
            os_log("notification.userInfo: %@",
                   log: Logger.shared.log,
                   type: .debug,
                   String(describing:notification.userInfo))
            configureView()
        }
    }

}

