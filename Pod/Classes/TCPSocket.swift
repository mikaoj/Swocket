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

public final class TCPSocket : Listenable, Transmittable, Connectable, Asyncable {
    // MARK: Private data
    private var connectionDescriptor: Int32?
    private let commonSocket: Socket
    private let maxRecieveSize = 100
    private let maxPendingConnections: Int32 = 10
    
    // MARK: Async vars
    public var dispatchQueue: dispatch_queue_t {
        get {
            return commonSocket.dispatchQueue
        }
    }
    
    public var callbackQueue: dispatch_queue_t {
        get {
            return commonSocket.callbackQueue
        }
    }
    
    // MARK: Connectable vars
    public final var connected: Bool {
        get {
            return connectionDescriptor != nil
        }
    }
    
    // MARK: Init
    public init(host: String, port: UInt) {
        commonSocket = Socket(host: host,
            port: port,
            callback: dispatch_get_main_queue(),
            dispatch: dispatch_queue_create("TCP:\(host):\(port)", nil)
        )
    }
    
    // MARK: Deinit
    deinit {
        // Make sure we disconnect on dealloc. Ignore any errors
        do { try disconnect() } catch { }
    }
    
    // MARK: Connectable functions
    public final func connect() throws {
        if connected {
            throw SwocketError.AlreadyConnected
        }
        
        // -1 Indicates connection failure
        if let descriptor = swocket_connect(commonSocket.port, commonSocket.host) as Int32? where descriptor != -1 {
            connectionDescriptor = descriptor
        } else {
            throw SwocketError.FailedToConnect
        }
    }
    
    public final func disconnect() throws {
        guard let descriptor = connectionDescriptor else {
            throw SwocketError.NotConnected
        }
    
        close(descriptor)
        connectionDescriptor = nil
    }
    
    // MARK: Transmittable functions
    public final func sendData(data: NSData) throws {
        guard let descriptor = connectionDescriptor else {
            throw SwocketError.NotConnected
        }
        
        try sendAll(data, descriptor: descriptor, totalSent: 0, bytesLeft: data.length, chunkSize: 0)
    }
    
    public final func recieveData() throws -> NSData {
        guard let descriptor = connectionDescriptor else {
            throw SwocketError.NotConnected
        }
        
        var zero: Int8 = 0
        let data = NSMutableData(bytes: &zero, length: maxRecieveSize)
        let dataPointer = UnsafeMutablePointer<Void>(data.mutableBytes)
        
        let numberOfBytes = recv(descriptor, dataPointer, maxRecieveSize-1, 0)
        
        // 0 bytes == connection closed
        if numberOfBytes == 0 {
            try disconnect()
            throw SwocketError.ConnectionClosed
        } else if numberOfBytes == -1 {
            perror("recv")
            throw SwocketError.FailedToRecieve
        } else {
            return NSData(bytes: data.bytes, length: numberOfBytes)
        }
    }
    
    // MARK: Listenable
    public static func listen(port: UInt, onConnection connectionClosure: SwocketNewConnectionClosure) throws -> Listenable {
        let server = TCPSocket(host: ":", port: port)
        
        let sockfd = swocket_listen(server.commonSocket.port, server.maxPendingConnections)
        
        // -1 == failure
        if sockfd == -1 {
            throw SwocketError.FailedToListen
        }
        
        // Assign listen descriptor
        server.connectionDescriptor = sockfd
        
        // Dispatch accept loop
        dispatch_async(server.dispatchQueue) { () -> Void in
            while server.connectionDescriptor != nil {
                let clientDescriptor = swocket_accept(sockfd)
                
                // Failed to accept, but continue accept loop
                if clientDescriptor == -1 {
                    continue
                }
                
                // Return incoming connection
                dispatch_async(server.callbackQueue) { () -> Void in
                    // Create a TCPSocket and send to connection closure
                    let client = TCPSocket(host: "", port: port)
                    client.connectionDescriptor = clientDescriptor
                    connectionClosure(client)
                    
                    // Disconnect after closure has ben run. Ignore errors, user may have disconnected it already
                    do { try client.disconnect() } catch { }
                }
            }
        }
        
        return server
    }
    
    public final func stop() throws {
        try disconnect()
    }
    
    // MARK: Private
    private final func sendAll(data: NSData, descriptor: Int32, totalSent: Int, bytesLeft: Int, chunkSize: Int) throws {
        if chunkSize == -1 {
            throw SwocketError.FailedToSend
        } else if bytesLeft == 0 {
            return
        } else {
            let chunkSize = send(descriptor, data.bytes+totalSent, bytesLeft, 0)
            try sendAll(data, descriptor: descriptor, totalSent: totalSent+chunkSize, bytesLeft: bytesLeft-chunkSize, chunkSize: chunkSize)
        }
    }
}
