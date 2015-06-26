//
//  TestTCPErrors.swift
//  Swocket
//
//  Created by Joakim Gyllström on 2015-06-26.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Swocket

class TestTCPErrors: XCTestCase {
    var client = TCPSocket(host: "127.0.0.1", port: 8899)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSendNotConnected() {
        do {
            let data = "Hello".dataUsingEncoding(NSUTF8StringEncoding)!
            try client.sendData(data)
            XCTAssert(false)
        } catch {
            switch error {
            case SwocketError.NotConnected:
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
    }
    
    func testRecieveNotConnected() {
        do {
            let _ = try client.recieveData()
            XCTAssert(false)
        } catch {
            switch error {
            case SwocketError.NotConnected:
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
    }
    
    func testDisconnectNotConnected() {
        do {
            try client.disconnect()
            XCTAssert(false)
        } catch {
            switch error {
            case SwocketError.NotConnected:
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
    }
}
