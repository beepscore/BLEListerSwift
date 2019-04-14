//
//  BLEDiscovery.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log

class BLEDiscovery: NSObject {

    enum Notification: String {
        case didRefresh = "didRefresh"
        case statePoweredOff = "statePoweredOff"
        case didConnectPeripheral = "didConnectPeripheral"
        case didDisconnectPeripheral = "didDisconnectPeripheral"
        case didDiscoverServices = "didDiscoverServices"
        case didReadRSSI = "didReadRSSI"

    }

    var centralManager: CBCentralManager? = nil
    var foundPeripherals: [CBPeripheral] = []
    var connectedServices: [CBService]? = []
    var notificationCenter: NotificationCenter? = nil

    var isFirstRun = true

    // MARK: - initializers

    // https://stackoverflow.com/questions/39628277/singleton-with-swift-3-0?noredirect=1&lq=1
    // https://stackoverflow.com/questions/37953317/singleton-with-properties-in-swift-3
    static let shared: BLEDiscovery = {

        // self isn't complete yet, so at first set CBCentralManagerDelegate to nil
        // later code should set delegate to self
        // queue nil uses main queue
        let cm = CBCentralManager(delegate: nil, queue: nil)

        let instance = BLEDiscovery(withCentralManager: cm,
                                    foundPeripherals: [CBPeripheral](),
                                    connectedServices: [CBService](),
                                    notificationCenter: NotificationCenter.default)
        return instance
    }()

    // make init private so other objects must use the shared singleton
    private override init() {}

    // unit tests can't access private method
    // unit test shared instead
    private init(withCentralManager centralManager: CBCentralManager,
                 foundPeripherals: [CBPeripheral],
                 connectedServices: [CBService],
                 notificationCenter: NotificationCenter) {
        super.init()

        self.centralManager = centralManager
        self.centralManager?.delegate = self

        self.foundPeripherals = foundPeripherals
        self.connectedServices = connectedServices
        self.notificationCenter = notificationCenter
    }


    // MARK: - Discovery

    /// safe method only scans if powered on
    /// https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals
    func safeScanForPeripherals() {
        os_log("safeScanForPeripherals", log: Logger.shared.log, type: .debug)

        guard let cm = self.centralManager else {
            return
        }
        let serviceUUIDs: [CBUUID]? = nil
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        cm.safeScanForPeripherals(withServices: serviceUUIDs, options: options)

        // stop scan after timeout
        // This stops generating callbacks to CBCentralManagerDelegate method
        // central manager didDiscover peripheral, advertisementData, rssi
        // https://stackoverflow.com/questions/24007518/how-can-i-use-nstimer-in-swift#24007862
        let _ = Timer.scheduledTimer(timeInterval: 4.0,
                                     target: self,
                                     selector: #selector(stopScan),
                                     userInfo: nil,
                                     repeats: false)
    }

//    func startScanningForUUIDString(uuidString: String) {
//        guard let cm = self.centralManager else {
//            return
//        }
//
//        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
//
//        if uuidString.isEmpty {
//            // BLE requires device, not simulator
//            // If running simulator, app crashes here with "bad access".
//            // Also Apple says services argument nil works, but is not recommended.
//            cm.safeScanForPeripherals(withServices: nil, options: options)
//        } else {
//            let uuid = CBUUID(string: uuidString)
//            let uuids = [uuid]
//
//            // NOTE: scanForPeripheralsWithServices:options:
//            // services is array of CBUUID not NSUUID
//            // Applications that have specified the bluetooth-central background mode
//            // are allowed to scan while backgrounded, with two caveats:
//            // the scan must specify one or more service types in serviceUUIDs,
//            // and the CBCentralManagerScanOptionAllowDuplicatesKey scan option will be ignored.
//            cm.safeScanForPeripherals(withServices: uuids, options: options)
//        }
//    }

    @objc func stopScan() {
        guard let cm = self.centralManager else {
            return
        }
        cm.stopScan()
    }

    // MARK: - Connect/Disconnect

    func connectPeripheral(peripheral: CBPeripheral) {
        guard let cm = centralManager else { return }

        if peripheral.state == .disconnected {
            cm.connect(peripheral, options: nil)
        }
    }

    func disconnectPeripheral(peripheral: CBPeripheral) {
        guard let cm = centralManager else { return }
        // don't check if peripheral.state == .connected, because it may be pending
        cm.cancelPeripheralConnection(peripheral)
    }

    // MARK: - post notifications

    /// Uses dependency injection
    /// - Parameter notificationCenter
    func postDidRefresh(notificationCenter: NotificationCenter?,
                        userInfo: [String: Any]?) {
        guard let nc = notificationCenter else { return }

        DispatchQueue.main.async {
            nc.post(name: NSNotification.Name(rawValue: BLEDiscovery.Notification.didRefresh.rawValue),
                    object: self,
                    userInfo: userInfo)
        }
    }

    /// Uses dependency injection
    /// - Parameter notificationCenter
    func postPoweredOff(notificationCenter: NotificationCenter?,
                        userInfo: [String: Any]?) {
        guard let nc = notificationCenter else { return }

        DispatchQueue.main.async {
            nc.post(name: NSNotification.Name(rawValue: BLEDiscovery.Notification.statePoweredOff.rawValue),
                    object: self,
                    userInfo: userInfo)
        }
    }

    func postDidConnectPeripheral(notificationCenter: NotificationCenter?,
                                  userInfo: [String: Any]?) {
        guard let nc = notificationCenter else { return }

        DispatchQueue.main.async {
            nc.post(name: NSNotification.Name(rawValue: BLEDiscovery.Notification.didConnectPeripheral.rawValue),
                    object: self,
                    userInfo: userInfo)
        }
    }

    func postDidDisconnectPeripheral(notificationCenter: NotificationCenter?,
                                     userInfo: [String: Any]?) {
        guard let nc = notificationCenter else { return }

        DispatchQueue.main.async {
            nc.post(name: NSNotification.Name(rawValue: BLEDiscovery.Notification.didDisconnectPeripheral.rawValue),
                    object: self,
                    userInfo: userInfo)
        }
    }

    func postDidDiscoverServices(notificationCenter: NotificationCenter?,
                                     userInfo: [String: Any]?) {
        guard let nc = notificationCenter else { return }

        DispatchQueue.main.async {
            nc.post(name: NSNotification.Name(rawValue: BLEDiscovery.Notification.didDiscoverServices.rawValue),
                    object: self,
                    userInfo: userInfo)
        }
    }

    func postDidReadRSSI(notificationCenter: NotificationCenter?,
                                 userInfo: [String: Any]?) {
        guard let nc = notificationCenter else { return }

        DispatchQueue.main.async {
            nc.post(name: NSNotification.Name(rawValue: BLEDiscovery.Notification.didReadRSSI.rawValue),
                    object: self,
                    userInfo: userInfo)
        }
    }

    // MARK: -

    func clearDevices() {
        self.foundPeripherals = []
        // TODO: reset each service before removing it? Reference Apple TemperatureSensor project
        self.connectedServices = []
    }

    func loadSavedDevices() {
        // FIXME: implement
        //
    }
}

extension BLEDiscovery: CBCentralManagerDelegate {
    // MARK: CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        os_log("centralManagerDidUpdateState", log: Logger.shared.log, type: .debug)
        os_log("central: %@ state: %@",
               log: Logger.shared.log,
               type: .debug,
               String(describing:central),
               String(describing:central.state))

        switch central.state {

        case .unknown:
            // wait for another event
            break

        case .resetting:
            clearDevices()
            self.postDidRefresh(notificationCenter: self.notificationCenter, userInfo: nil)
            //[peripheralDelegate alarmServiceDidReset];

        case .unsupported:
            // original code didn't list this case and Xcode warned
            // so list case to silence warning, but don't do anything
            break

        case .unauthorized:
            // Tell user the app is not allowed
            break

        case .poweredOff:
            self.clearDevices()
            self.postDidRefresh(notificationCenter: self.notificationCenter, userInfo: nil)

            // Tell user to power ON BT for functionality, but not on first run
            // the Framework will alert in that instance.
            if !isFirstRun {
                self.postPoweredOff(notificationCenter: self.notificationCenter, userInfo: nil)
            }

        case .poweredOn:
            self.loadSavedDevices()

            // FIXME: specify serviceUUIDs
            // "The list of connected peripherals can include those that are connected by other apps and that will need to be connected locally using the connect(_:options:) method before they can be used."
            // let peripherals = retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID])

            // Add to list.
            // for peripheral in peripherals {
            // "Attempts to connect to a peripheral do not time out."
            //                [central connectPeripheral:peripheral options:nil];
            //            }
            self.postDidRefresh(notificationCenter: self.notificationCenter, userInfo: nil)

        @unknown default:
            break
        }

        isFirstRun = false
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi: NSNumber) {

        os_log("centralManager didDiscover", log: Logger.shared.log, type: .debug)
        os_log("foundPeripherals.count: %@",
               log: Logger.shared.log,
               type: .debug,
               String(describing: foundPeripherals.count))

        os_log("%@", log: Logger.shared.log, type: .debug,
               foundPeripherals.description)

        // checking peripheral.name != nil prevents blank appearing rows in table view
        if peripheral.name != nil && !(foundPeripherals.contains(peripheral)) {
            peripheral.delegate = self as CBPeripheralDelegate
            foundPeripherals.append(peripheral)
        }

        // Argument rssi may be non-nil even when peripheral.rssi is nil??
        let userInfo: [String: Any] = ["central" : central,
                                       "peripheral" : peripheral,
                                       "advertisementData" : advertisementData,
                                       "rssi" : rssi]

        postDidRefresh(notificationCenter: notificationCenter, userInfo: userInfo)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

        let userInfo: [String: Any] = ["peripheral": peripheral]
        postDidConnectPeripheral(notificationCenter: notificationCenter,
                                 userInfo: userInfo)
        
        peripheral.delegate = self as CBPeripheralDelegate

        // must be connected to call readRSSI
        // readRSSI calls back delegate method peripheral:didReadRSSI:error:
        peripheral.readRSSI()

        // discoverServices calls back delegate method peripheral:didDiscoverServices:
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {

        if let error = error {
            os_log("centralManager didDisconnectPeripheral error: %@",
                   log: Logger.shared.log,
                   type: .error,
                   error.localizedDescription)
        }

        let userInfo: [String: Any] = ["peripheral": peripheral]
        postDidDisconnectPeripheral(notificationCenter: notificationCenter,
                                    userInfo: userInfo)
    }

}

extension BLEDiscovery: CBPeripheralDelegate {
// MARK: CBPeripheralDelegate
// CBPeripheralDelegate has no required methods
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBPeripheralDelegate_Protocol/translated_content/CBPeripheralDelegate.htm

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices: Error?) {

        if let error = didDiscoverServices {
            os_log("peripheral didDiscoverServices error: %@",
                   log: Logger.shared.log,
                   type: .error,
                   error.localizedDescription)
        } else {
            let userInfo: [String: Any] = ["peripheral": peripheral]
            postDidDiscoverServices(notificationCenter: notificationCenter,
                                    userInfo: userInfo)
        }

    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {

        if let error = error {
            os_log("peripheral didReadRSSI error: %@",
                   log: Logger.shared.log,
                   type: .error,
                   error.localizedDescription)
        } else {
            let userInfo: [String: Any] = ["peripheral": peripheral, "rssi": RSSI]
            postDidReadRSSI(notificationCenter: notificationCenter,
                            userInfo: userInfo)
        }
    }

}
