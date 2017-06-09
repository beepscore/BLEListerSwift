//
//  MasterViewControllerTests.swift
//  BLEListerSwift
//
//  Created by Steve Baker on 6/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import BLEListerSwift

class MasterViewControllerTests: XCTestCase {

    func testViewDidLoadSetsBLEDiscovery () {
        let vc = MasterViewController()
        XCTAssertNil(vc.bleDiscovery)
        vc.viewDidLoad()
        XCTAssertNotNil(vc.bleDiscovery)
    }

}
