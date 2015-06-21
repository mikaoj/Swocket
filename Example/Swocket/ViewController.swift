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
    
    // Set up a socket to localhost on port 9999
    let client = Swocket(port: 9999, host: "127.0.0.1")
    
    @IBAction func send(sender: UIButton) {
        // Get text to send
        if let data = messageField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
            // Connect to server
            client.connect()
            
            // Send message
            client.send(data)
            
            // Get response
            client.recieve({ (socket, data) -> () in
                // Unwrap response as string and set response label
                let pointer = UnsafePointer<CChar>(data.bytes)
                if let response = String(CString: pointer, encoding: NSUTF8StringEncoding) {
                    self.responseLabel.text = response
                }
            })
            
            // Disconnect
            client.disconnect()
        }
    }
}

