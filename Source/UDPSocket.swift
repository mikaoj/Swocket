// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public class UDPSocket : Asyncable, Transmittable, Connectable {
    // MARK: Private data
    private let commonSocket: Socket
    
    // MARK: Async vars
    public final var dispatchQueue: dispatch_queue_t {
        get {
            return commonSocket.dispatchQueue
        }
    }
    
    public final var callbackQueue: dispatch_queue_t {
        get {
            return commonSocket.callbackQueue
        }
    }
    
    // MARK: Connectable vars
    public final let connected = true
    
    // MARK: Init
    public required init(host: String, port: UInt) {
        commonSocket = Socket(host: host,
            port: port,
            callback: dispatch_get_main_queue(),
            dispatch: dispatch_queue_create("TCP:\(host):\(port)", nil)
        )
    }
    
    // MARK: Connectable functions
    public final func connect() throws { }
    public final func disconnect() throws { }
    
    // MARK: Transmittable
    public final func sendData(data: NSData) throws {
        
    }

    public final func recieveData() throws -> NSData {
        return NSData()
    }
}
