//
//  CBCentralManagerExtension.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log

public extension CBCentralManager {

    /// After calling safeScanForPeripherals,
    /// CBCentralManagerDelegate method central manager didDiscover peripheral, advertisementData, rssi will be called every few seconds until scan is stopped.
    /// safe method only scans if powered on
    /// https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals
    func safeScanForPeripherals(withServices serviceUUIDs: [CBUUID]?,
                                options: [String : Any]? = nil) {
        if self.state != .poweredOn {
            os_log("CBCentralManager not powered on, didn't scan.",
                   log: Logger.shared.log,
                   type: .debug)
            return
        }
        os_log("CBCentralManager powered on, calling scanForPeripheralsWithServices.",
               log: Logger.shared.log,
               type: .debug)
        self.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }

}
