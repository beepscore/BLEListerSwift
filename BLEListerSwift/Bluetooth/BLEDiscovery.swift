//
//  BLEDiscovery.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BLEDiscoveryConstants {
    static let didRefreshNotification = NSNotification.Name(rawValue: "didRefreshNotification")
    static let statePoweredOffNotification = NSNotification.Name(rawValue: "statePoweredOffNotification")
}

class BLEDiscovery: NSObject {

    var centralManager: CBCentralManager? = nil
    var foundPeripherals: [CBPeripheral]? = []
    var connectedServices: [CBService]? = []
    var notificationCenter: NotificationCenter? = nil

    var isFirstRun = true

    // MARK: - initializers

    // https://stackoverflow.com/questions/39628277/singleton-with-swift-3-0?noredirect=1&lq=1
    // https://stackoverflow.com/questions/37953317/singleton-with-properties-in-swift-3
    static let shared: BLEDiscovery = {

        // queue nil uses main queue
        let cm = CBCentralManager(delegate: self as? CBCentralManagerDelegate, queue: nil)

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
        self.centralManager = centralManager
        self.foundPeripherals = foundPeripherals
        self.connectedServices = connectedServices
        self.notificationCenter = notificationCenter
    }


    // MARK: - Discovery

    /// safe method only scans if powered on
    /// https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals
    func safeScanForPeripherals(withServices serviceUUIDs: [CBUUID]?,
                                options: [String : Any]? = nil) {
        guard let cm = self.centralManager else {
            return
        }
        cm.safeScanForPeripherals(withServices: serviceUUIDs, options: options)
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
//
//    func stopScan() {
//        guard let cm = self.centralManager else {
//            return
//        }
//        cm.stopScan()
//    }

}

extension BLEDiscovery: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        print(String(describing:central) + "central.state: " + String(describing:central.state))

        switch central.state {

        case .unknown:
            // wait for another event
            break

        case .resetting:
            clearDevices()
            self.postDidRefresh(notificationCenter: self.notificationCenter)
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
            self.postDidRefresh(notificationCenter: self.notificationCenter)

            // Tell user to power ON BT for functionality, but not on first run
            // the Framework will alert in that instance.
            if !isFirstRun {
                self.postPoweredOff(notificationCenter: self.notificationCenter)
            }

        case .poweredOn:
            self.loadSavedDevices()

            // FIXME: specify services argument
            //NSArray *peripherals = [central retrieveConnectedPeripheralsWithServices:@[]];

            // Add to list.
            //            for (CBPeripheral *peripheral in peripherals) {
            //                // method documentation: Attempts to connect to a peripheral do not time out.
            //                [central connectPeripheral:peripheral options:nil];
            //            }
            self.postDidRefresh(notificationCenter: self.notificationCenter)
        }

        isFirstRun = false
    }

    /// Uses dependency injection
    /// - Parameter notificationCenter
    func postDidRefresh(notificationCenter: NotificationCenter?) {
        guard let nc = notificationCenter else {
            return
        }
        nc.post(name: BLEDiscoveryConstants.didRefreshNotification,
                object: self,
                userInfo: nil)
    }

    /// Uses dependency injection
    /// - Parameter notificationCenter
    func postPoweredOff(notificationCenter: NotificationCenter?) {
        guard let nc = notificationCenter else {
            return
        }
        nc.post(name: BLEDiscoveryConstants.statePoweredOffNotification,
                object: self,
                userInfo: nil)
    }

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
