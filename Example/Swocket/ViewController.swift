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
    // Set up a socket to localhost on port 9999
    let client = Swocket(port: 9999, host: "127.0.0.1")
    
    @IBAction func send(sender: UIButton) {
        // Send data
        try! client.send { (socket) -> (NSData?) in
            return "Eat shit!".dataUsingEncoding(NSUTF8StringEncoding)
        }
        client.close() // TODO: Shouldn't be needed
    }
}

