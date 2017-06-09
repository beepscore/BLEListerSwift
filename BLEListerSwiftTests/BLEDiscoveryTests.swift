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

    func testSharedCentralManager () {
        let shared = BLEDiscovery.shared
        XCTAssertNotNil(shared.centralManager)
    }

    func testSharedFoundPeripherals () {
        let shared = BLEDiscovery.shared
        XCTAssertNotNil(shared.foundPeripherals)
    }

    func testSharedConnectedServices () {
        let shared = BLEDiscovery.shared
        XCTAssertNotNil(shared.connectedServices)
    }

    func testSharedNotificationCenter () {
        let shared = BLEDiscovery.shared
        XCTAssertEqual(shared.notificationCenter, NotificationCenter.default)
    }

    // MARK: test post notifications

    /// Asynchronous test
    /// https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations/testing_asynchronous_operations_with_expectations
    /// Alternatively could use more verbose XCTWaiter and check it returns .completed
    /// http://masilotti.com/xctest-waiting/
    /// http://shashikantjagtap.net/asynchronous-ios-testing-swift-xcwaiter/
    func testPostDidRefresh () {
        let shared = BLEDiscovery.shared
        let ncDefault = NotificationCenter.default

        // XCTNSNotificationExpectation is fulfilled iff notification is posted
        let expectation = XCTNSNotificationExpectation(name: BLEDiscoveryConstants.didRefreshNotification.rawValue,
                                                       object: shared,
                                                       notificationCenter: ncDefault)

        // call method under test
        shared.postDidRefresh(notificationCenter: shared.notificationCenter)

        // wait until the expectation is fulfilled
        wait(for: [expectation], timeout: 1.0)
    }

    func testPostPoweredOff () {
        let shared = BLEDiscovery.shared
        let ncDefault = NotificationCenter.default

        // XCTNSNotificationExpectation is fulfilled iff notification is posted
        let expectation = XCTNSNotificationExpectation(name: BLEDiscoveryConstants.statePoweredOffNotification.rawValue,
                                                       object: shared,
                                                       notificationCenter: ncDefault)

        // call method under test
        shared.postPoweredOff(notificationCenter: shared.notificationCenter)

        // wait until the expectation is fulfilled
        wait(for: [expectation], timeout: 1.0)
    }

}
