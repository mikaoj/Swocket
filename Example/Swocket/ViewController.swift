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
    let client = Swocket(host: "127.0.0.1", port: 9999)
    
    @IBAction func send(sender: UIButton) {
        // Get text to send and convert to NSData
        if let data = messageField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
            // Connect to server
            client.connect()
            
            // Send message
            client.send(data)
            
            // Get response
            client.recieve({ (socket, data) -> () in
                // Unwrap response as string and set response label
                if let response = String(CString: UnsafePointer<CChar>(data.bytes), encoding: NSUTF8StringEncoding) {
                    self.responseLabel.text = response
                }
            })
            
            // Disconnect
            client.disconnect()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let data = "Wazzzup\n".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Swocket.listen(1337, onConnection: { (client) -> () in
            client.send(data)
        })
    }
}

