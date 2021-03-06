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
    
    @IBOutlet weak var advertisementLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!

    @IBOutlet weak var connectButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bleDiscovery = BLEDiscovery.shared
        registerForNotifications()

        configureView()

        // TODO: scan for services, show them
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var peripheral: CBPeripheral? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    /// Update the user interface for the detail item
    func configureView() {
        if let peripheral = peripheral {

            let advertisementDataText = bleDiscovery?.advertisementDatas[peripheral.identifier].debugDescription

            // may be nil
            let rssiValue = bleDiscovery?.rssis[peripheral.identifier] as? NSNumber
            var rssiValueText = "-"
            if let rssiValueUnwrapped = rssiValue {
                rssiValueText = "\(rssiValueUnwrapped)"
            }

            os_log("configureView peripheral name: %@\nidentifier: %@\nadvertisement: %@\nrssi: %@\nservices: %@",
                   log: Logger.shared.log,
                   type: .debug,
                   peripheral.name ?? "-",
                   peripheral.identifier.description,
                   advertisementDataText ?? "-",
                   rssiValueText,
                   peripheral.services?.description ?? "-")

            title = peripheral.name ?? "-"
            if let identifierLabel = identifierLabel {
                identifierLabel.text = peripheral.identifier.debugDescription
            }
            if let advertisementLabel = advertisementLabel {
                advertisementLabel.text = advertisementDataText
            }
            if let rssiLabel = rssiLabel {
                rssiLabel.text = rssiValueText
            }
            if let servicesLabel = servicesLabel {
                servicesLabel.text = peripheral.services.debugDescription
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
            
        case .connected:
            connectLabelText = NSLocalizedString("Disconnect", comment: "Disconnect")
        case .connecting:
            connectLabelText = NSLocalizedString("connecting...", comment: "connecting...")
        case .disconnected:
            connectLabelText = NSLocalizedString("Connect", comment: "Connect")
        case .disconnecting:
            connectLabelText = NSLocalizedString("disconnecting...", comment: "disconnecting...")
        default:
            connectLabelText = "-"
        }
        return connectLabelText;
    }

    @IBAction func discoverCharacteristicsTapped(sender: Any) {
        guard let discovery = bleDiscovery, let peripheral = peripheral else { return }
        discovery.discoverAllServicesCharacteristics(peripheral: peripheral)
        // update UI based on detailItem state
        configureView();
    }

    // MARK: - Connect / Disconnect

    @IBAction func connectTapped(sender: Any) {
        guard let discovery = bleDiscovery, let peripheral = peripheral else { return }
        switch (peripheral.state) {
        case .connected:
            disconnect(discovery: discovery, peripheral: peripheral)
        case .disconnected:
            connect(discovery: discovery, peripheral: peripheral)
        case .connecting, .disconnecting:
            break
        default:
            break
        }
        // update UI based on peripheral state
        configureView();
    }

    func connect(discovery: BLEDiscovery, peripheral: CBPeripheral) {
        discovery.connectPeripheral(peripheral: peripheral)
    }

    func disconnect(discovery: BLEDiscovery, peripheral: CBPeripheral) {
        discovery.disconnectPeripheral(peripheral: peripheral)
    }

    // MARK: - Register for notifications

    func registerForNotifications() {
        registerForBleDiscoveryDidConnectPeripheralNotification()
        registerForBleDiscoveryDidDisconnectPeripheralNotification()
        registerForBleDiscoveryDidDiscoverServicesNotification()
        registerForBleDiscoveryDidDiscoverCharacteristicsNotification()
        registerForBleDiscoveryDidReadRSSINotification()
    }

    func registerForBleDiscoveryDidConnectPeripheralNotification() {
        guard let nc = bleDiscovery?.notificationCenter else { return }

        nc.addObserver(self,
                       selector:#selector(discoveryDidConnectPeripheralWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didConnectPeripheral.rawValue),
                       object:nil)
    }

    func registerForBleDiscoveryDidDisconnectPeripheralNotification() {
        guard let nc = bleDiscovery?.notificationCenter else { return }

        nc.addObserver(self,
                       selector:#selector(discoveryDidDisconnectPeripheralWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didDisconnectPeripheral.rawValue),
                       object:nil)
    }

    func registerForBleDiscoveryDidDiscoverServicesNotification() {
        guard let nc = bleDiscovery?.notificationCenter else { return }

        nc.addObserver(self,
                       selector:#selector(discoveryDidDiscoverServicesWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didDiscoverServices.rawValue),
                       object:nil)
    }

    func registerForBleDiscoveryDidDiscoverCharacteristicsNotification() {
        guard let nc = bleDiscovery?.notificationCenter else { return }

        nc.addObserver(self,
                       selector:#selector(discoveryDidDiscoverCharacteristicsWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didDiscoverCharacteristics.rawValue),
                       object:nil)
    }

    func registerForBleDiscoveryDidReadRSSINotification() {
        guard let nc = bleDiscovery?.notificationCenter else { return }

        nc.addObserver(self,
                       selector:#selector(discoveryDidReadRSSIWithNotification(_:)),
                       name:NSNotification.Name(rawValue: BLEDiscovery.Notification.didReadRSSI.rawValue),
                       object:nil)
    }


    // MARK: - Notification handlers

    /// May be used to filter notifications by specified peripheral
    /// - Parameters:
    ///   - notification:
    ///   - peripheral:
    /// - Returns: true if notification userInfo contains peripheral, else returns false.
    ///   returns false if userInfo or peripheral is nil
    func notificationContainsPeripheral(_ notification: NSNotification,
                                        peripheral: CBPeripheral?) -> Bool {
        if notification.userInfo == nil { return false }
        guard let notificationPeripheral = notification.userInfo?[BLEDiscovery.UserInfoKeys.peripheral.rawValue] as? CBPeripheral
            else { return false }
        return notificationPeripheral == peripheral
    }

    @objc func discoveryDidConnectPeripheralWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidConnectPeripheralWithNotification",
               log: Logger.shared.log,
               type: .debug)

        if notificationContainsPeripheral(notification, peripheral: peripheral) {
            configureView()
        }
    }

    @objc func discoveryDidDisconnectPeripheralWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidDisconnectPeripheralWithNotification",
               log: Logger.shared.log,
               type: .debug)

        if notificationContainsPeripheral(notification, peripheral: peripheral) {
            configureView()
        }
    }

    @objc func discoveryDidDiscoverServicesWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidDiscoverServicesWithNotification",
               log: Logger.shared.log,
               type: .debug)

        if notificationContainsPeripheral(notification, peripheral: peripheral) {
            configureView()
        }
    }

    @objc func discoveryDidDiscoverCharacteristicsWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidDiscoverCharacteristicsWithNotification",
               log: Logger.shared.log,
               type: .debug)

        if notificationContainsPeripheral(notification, peripheral: peripheral) {
            configureView()
        }
    }

    @objc func discoveryDidReadRSSIWithNotification(_ notification: NSNotification) {
        os_log("DetailViewController discoveryDidReadRSSIWithNotification",
               log: Logger.shared.log,
               type: .debug)

        if notificationContainsPeripheral(notification, peripheral: peripheral) {
            configureView()
        }
    }

}

