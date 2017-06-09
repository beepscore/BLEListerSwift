//
//  BLEDiscoveryTests.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import BLEListerSwift

class BLEDiscoveryTests: XCTestCase {
    
    func testBLEDiscoverySharedNotNil () {
        let shared0 = BLEDiscovery.shared
        XCTAssertNotNil(shared0)
    }

    func testBLEDiscoverySharedReturnsSameObject () {
        let shared0 = BLEDiscovery.shared
        let shared1 = BLEDiscovery.shared
        XCTAssertTrue(shared1 === shared0)
    }
}
