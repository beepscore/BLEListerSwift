//
//  CBCentralManagerExtension.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

public extension CBCentralManager {

    /// safe method only scans if powered on
    /// https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals
    func safeScanForPeripherals(withServices serviceUUIDs: [CBUUID]?,
                                options: [String : Any]? = nil) {
        if self.state != .poweredOn {
            print("CBCentralManager not powered on, didn't scan.")
            return
        }
        print("CBCentralManager powered on, calling scanForPeripheralsWithServices.")
        self.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }

}
