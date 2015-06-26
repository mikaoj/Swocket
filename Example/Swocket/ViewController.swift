//
//  ViewController.swift
//  Swocket
//
//  Created by Joakim Gyllstrom on 06/19/2015.
//  Copyright (c) 06/19/2015 Joakim Gyllstrom. All rights reserved.
//

import UIKit
import Swocket

class ViewController: UIViewController {
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var messageField: UITextField!
    var server: Listenable?
    
    // Set up a socket to localhost on port 9999
    let client = Swocket.TCP.init(host: "127.0.0.1", port: 9999)
    
    @IBAction func send(sender: UIButton) {
        // Get text to send and convert to NSData
        if let data = messageField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
            // Connect to server
            try! client.connect()

            // Send message
            try! client.sendData(data)
            
            // Get response
            client.recieveDataAsync({ (data, error) -> Void in
                // Unwrap response as string and set response label
                let response = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
                self.responseLabel.text = response
                try! self.client.disconnect()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let httpString = "HTTP/1.1 200 OK\nContent-Type: text/html; charset=UTF-8"
        let htmlString = "<html><head><title>Hello</title></head><body><h1>Hello World!</h1><p>I am a tiny little web server</p></body></html>"
        let data = "\(httpString)\n\n\(htmlString)".dataUsingEncoding(NSUTF8StringEncoding)!
        
        server = try! Swocket.TCP.listen(8080, onConnection: { (client) -> () in
            try! client.recieveData() // Ignore what client requests
            try! client.sendData(data) // And give them the same result every time! :P
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        try! server?.stop()
        
        viewDidDisappear(animated)
    }
}
