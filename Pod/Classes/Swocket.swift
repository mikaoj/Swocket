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

enum SwocketError: ErrorType {
    case Connection
    case Send
    case Recieve
}

public class Swocket { // TODO: Struct?
    private var sockfd: Int32?
    private let port: UInt
    private let host: String
    
    /**
    Listen for incomming connections on a given port.
    - Parameter port: The port to listen for connections on.
    - Parameter onConnection: A closure to handle incoming connections from.
    - Returns: The server socket.
    */
    public class func listen(port: UInt, onConnection: (server: Swocket, client: Swocket) -> ()) throws -> Swocket {
        
        return Swocket(port: port, host: "")
    }
    
    /**
    Send data through the socket.
    - Parameter send: A closure that gets called when socket is ready to send. Should return the NSData to send.
    - Returns: This socket so you can chain operations
    */
    public final func send(send: (socket: Swocket) -> (NSData?)) throws -> Swocket {
        if sockfd == nil {
            try connect()
        }
        
        // TODO: Dispatch!
        if let sockfd = sockfd, let data = send(socket: self) where swocket_send(sockfd, data.bytes, data.length) != -1 {
            return self
        } else {
            throw SwocketError.Send
        }
    }
    
    /**
    Recieve data from a socket.
    - Parameter recieve: Closure that get called with the recieving data.
    - Returns: This socket, so you can chain operations
    */
    public final func recieve(recieve: (socket: Swocket, data: NSData) -> ()) throws -> Swocket {
        return self
    }
    
    /**
    Close connection.
    */
    public final func close() {
        if let sockfd = sockfd {
            // Close socket
            swocket_close(sockfd)
            self.sockfd = nil
        }
    }
    
    public init(port: UInt, host: String) {
        self.port = port
        self.host = host
    }
    
    deinit {
        // Make sure we close connection on deallocation
        close()
    }
    
    private final func connect() throws {
        // Convert host and port to c strings
        guard let host = host.cStringUsingEncoding(NSUTF8StringEncoding), let port = String(port).cStringUsingEncoding(NSUTF8StringEncoding) else {
            throw SwocketError.Connection
        }
        
        // Try to connect, -1 indicates failure
        let newFd = swocket_connect(port, host)
        if newFd == -1 {
            throw SwocketError.Connection
        }
        
        // Assign socket descriptor
        sockfd = newFd
    }
}