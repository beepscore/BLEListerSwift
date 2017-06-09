//
//  BLEDiscovery.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation

class BLEDiscovery: NSObject {

    // https://stackoverflow.com/questions/39628277/singleton-with-swift-3-0?noredirect=1&lq=1
    // https://stackoverflow.com/questions/37953317/singleton-with-properties-in-swift-3
    static let shared: BLEDiscovery = {
        let instance = BLEDiscovery()
        // setup code
        return instance
    }()

    // make init private so other objects must use the shared singleton
    private override init() {}

}
