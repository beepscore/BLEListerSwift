//
//  BLEDiscovery.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEDiscovery: NSObject {

    var centralManager: CBCentralManager? = nil
    var foundPeripherals: [CBPeripheral]? = []
    var connectedServices: [CBService]? = []
    var notificationCenter: NotificationCenter? = nil

    // https://stackoverflow.com/questions/39628277/singleton-with-swift-3-0?noredirect=1&lq=1
    // https://stackoverflow.com/questions/37953317/singleton-with-properties-in-swift-3
    static let shared: BLEDiscovery = {
        let instance = BLEDiscovery(withCentralManager: CBCentralManager(),
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

}
