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
    
    @IBAction func send(sender: UIButton) {
        // Get text to send and convert to NSData
        if let data = messageField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
            var response = Packet()
            try! Socket.open("127.0.0.1", port: 8080).send(Packet(data)).receive(&response).close()

            let woop = NSData(bytes: response.bytes, length: response.length)
            responseLabel.text = String(data: woop, encoding: NSUTF8StringEncoding)!
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let httpString = "HTTP/1.1 200 OK\nContent-Type: text/html; charset=UTF-8"
        let htmlString = "<html><head><title>Hello</title></head><body><h1>Hello World!</h1><p>I am a tiny little web server</p></body></html>"
        let data = "\(httpString)\n\n\(htmlString)".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    override func viewDidDisappear(animated: Bool) {
        viewDidDisappear(animated)
    }
}
