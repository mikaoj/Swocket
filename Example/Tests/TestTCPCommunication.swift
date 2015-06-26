//
//  TestTCPCommunication.swift
//  Swocket
//
//  Created by Joakim Gyllström on 2015-06-26.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Swocket

class TestTCPCommunication: XCTestCase {
    var echoServer: Listenable!
    let port: UInt = 7755
    
    override func setUp() {
        super.setUp()
        
        echoServer = try! TCPSocket.listen(port, onConnection: { (client) -> Void in
            let data = try! client.recieveData()
            try! client.sendData(data)
        })
    }
    
    override func tearDown() {
        try! echoServer.stop()
        
        super.tearDown()
    }

    func testHello() {
        let client = TCPSocket(host: "127.0.0.1", port: port)
        let message = "Hello World!"
        let messageData = message.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let expectation = expectationWithDescription("In soviet russia, expectation expects you")
        
        client.connectAsync()
        client.sendDataAsync(messageData)
        client.recieveDataAsync { (response, error) -> Void in
            let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding) as! String
            XCTAssert(responseString == message)
            expectation.fulfill()
        }
        client.disconnectAsync()
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testMultiHello() {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 10
        
        // Setup a bunch of clients
        for i in 0..<50 {
            let message = "Hello World! \(i)"
            let messageData = message.dataUsingEncoding(NSUTF8StringEncoding)!
            let client = TCPSocket(host: "127.0.0.1", port: self.port)
            let expectation = self.expectationWithDescription("In soviet russia, expectation expects you")
            
            // Add them to operation queue
            queue.addOperationWithBlock({ () -> Void in
                client.connectAsync()
                client.sendDataAsync(messageData)
                sleep(arc4random_uniform(2)) // Random sleep
                client.recieveDataAsync { (response, error) -> Void in
                    let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding) as! String
                    XCTAssert(responseString == message)
                    XCTAssert(error == nil)
                    expectation.fulfill()
                }
                client.disconnectAsync()
            })
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
