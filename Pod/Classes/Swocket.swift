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

public enum SwocketError: ErrorType {
    case Connection
    case Send
    case Recieve
}

public typealias SwocketAsyncError = (error: SwocketError) -> ()

public class Swocket { // TODO: Struct?
    private var sockfd: Int32?
    private let port: [CChar]
    private let host: [CChar]
    private let dispatchQueue: dispatch_queue_t
    private let callbackQueue: dispatch_queue_t
    
    // MARK: Public functions
    public init(port: UInt, host: String, callback: dispatch_queue_t = dispatch_get_main_queue()) {
        // Forcefull unwrapp on purpose
        self.port = String(port).cStringUsingEncoding(NSUTF8StringEncoding)!
        self.host = host.cStringUsingEncoding(NSUTF8StringEncoding)!
        self.callbackQueue = callback
        dispatchQueue = dispatch_queue_create("\(host):\(port)", nil)
    }
    
    deinit {
        // Make sure we close connection on deallocation
        disconnect()
    }
    
    /**
    Listen for incomming connections on a given port.
    - Parameter port: The port to listen for connections on.
    - Parameter onConnection: A closure to handle incoming connections from.
    - Returns: The server socket.
    */
    public class func listen(port: UInt, onConnection: (server: Swocket, client: Swocket) -> (), error: SwocketAsyncError? = nil) -> Swocket {
        
        return Swocket(port: port, host: "")
    }
    
    /**
    Send data through the socket.
    - Parameter send: A closure that gets called when socket is ready to send. Should return the NSData to send.
    - Returns: This socket so you can chain operations
    */
    public final func send(data: NSData, error: SwocketAsyncError? = nil) -> Swocket {
        dispatch_async(dispatchQueue) { () -> Void in
            if let sockfd = self.sockfd {
                
                var totalSent = 0
                var bytesLeft = data.length
                var sentChunkSize = 0
                
                // Repeat until all bytes are sent, or we get an error
                repeat {
                    sentChunkSize = Foundation.send(sockfd, data.bytes+totalSent, bytesLeft, 0)
                    if sentChunkSize == -1 {
                        if let error = error {
                            error(error: SwocketError.Send)
                        }
                        break
                    }
                    
                    totalSent += sentChunkSize
                    bytesLeft -= sentChunkSize
                } while totalSent < data.length
            } else {
                if let error = error {
                    error(error: SwocketError.Send)
                }
            }
        }
        
        return self
    }
    
    /**
    Recieve data from a socket.
    - Parameter recieve: Closure that get called with the recieving data.
    - Returns: This socket, so you can chain operations
    */
    public final func recieve(recieve: (socket: Swocket, data: NSData) -> (), error: SwocketAsyncError? = nil) -> Swocket {
        
        dispatch_async(dispatchQueue) { () -> Void in
            if let sockfd = self.sockfd {
                let maxSize = 100
                var nullChar: Int8 = 0
                let data = NSMutableData(bytes: &nullChar, length: maxSize)
                let dataPtr = UnsafeMutablePointer<Void>(data.mutableBytes)
                
                let numBytes = recv(sockfd, dataPtr, maxSize-1, 0)
                
                dispatch_async(self.callbackQueue, { () -> Void in
                    recieve(socket: self, data: NSData(bytes: data.bytes, length: numBytes))
                })
            } else {
                // ERROR!
            }
        }
        
        return self
    }
    
    /**
    Close connection.
    */
    public final func disconnect() {
        dispatch_async(dispatchQueue) { () -> Void in
            if let sockfd = self.sockfd {
                // Close socket
                close(sockfd)
                self.sockfd = nil
            }
        }
    }
    
    // MARK: Private functions
    /**
    */
    public final func connect(error: SwocketAsyncError? = nil) {
        dispatch_async(dispatchQueue) { () -> Void in
            // Try to connect, -1 indicates failure
            let newFd = swocket_connect(self.port, self.host)
            if let error = error where newFd == -1 {
                error(error: SwocketError.Connection)
            }
            
            // Assign socket descriptor
            self.sockfd = newFd
        }
    }
}