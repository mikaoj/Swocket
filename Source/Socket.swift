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

public typealias Socket = Int
public typealias Host = String
public typealias Port = Int

public enum SocketError: ErrorType {
    case Open
    case Send
    case Receive
}

/// TCP - Transmission Control Protocol
public protocol TransmissionControl {
    /**
     Sets up a listening Socket on a given port.
     - parameter Port: The port to listen for connections on.
     - returns: Listening socket
     */
    static func listen(port: Port) throws -> Self

    /**
     Accepts incomming connections. Will block until an incomming connection arrives.
     - returns: Incomming socket
     */
    func accept() throws -> Self

    /**
     Opens a socket to a given host.
     - parameter host: The host to connect to
     - parameter port: The port to connect on
     - returns: An open socket
     */
    static func open(host: Host, port: Port) throws -> Self

    /**
     Closes an open socket.
     */
    func close() throws

    /**
     Sends a packet.
     - parameter Packet: Packet to send
     - returns: The current socket.
     */
    func send(packet: Packet) throws -> Self

    /**
     Receives a packet.
     - parameter Packet: The received packet.
     - parameter BufferSize: The size of receiving buffer.
     - returns: The current socket.
     */
    func receive(inout packet: Packet, bufferSize: Int) throws -> Self
}

/// UDP - User Datagram Protocol
public protocol UserDatagram {
    /**
     Send a Packet to a given host and port.
     - parameter host: The host to send to.
     - parameter port: The port to send on.
     - parameter packet: The packet to send.
     */
    static func sendTo(host: Host, port: Port, packet: Packet) throws

    /**
     Receives data on a given port.
     - parameter packet: The received packet.
     */
    static func receiveFrom(port: Port, inout packet: Packet) throws
}

extension Socket: TransmissionControl {
    public static func listen(port: Port) throws -> Socket {
        return 0
    }

    public func accept() throws -> Socket {
        return self
    }

    public static func open(host: Host, port: Port) throws -> Socket {
        let socket: Socket = Port(swocket_open(String(port).cStringUsingEncoding(NSUTF8StringEncoding)!, host.cStringUsingEncoding(NSUTF8StringEncoding)!))
        guard socket != -1 else { throw SocketError.Open }

        return socket
    }

    public func close() throws {
        swocket_close(Int32(self))
    }

    public func send(packet: Packet) throws -> Socket {
        return try sendAll(packet, totalSent: 0, bytesLeft: packet.length, chunkSize: 0)
    }

    public func receive(inout packet: Packet, bufferSize: Int = 1024) throws -> Socket {
        // Create zero filled buffer
        let buffer = NSMutableData(length: bufferSize)!

        // Receive bytes
        let receivedBytes = recv(Int32(self), buffer.mutableBytes, buffer.length, 0)

        // No received bytes or -1 represent errors
        if receivedBytes <= 0 {
            throw SocketError.Receive
        }

        // Truncate buffer to the length of the received data
        buffer.length = receivedBytes
        packet.append(buffer)

        return self
    }
}

extension Socket: UserDatagram {
    public static func sendTo(host: Host, port: Port, packet: Packet) throws {

    }

    public static func receiveFrom(port: Port, inout packet: Packet) throws {

    }
}

// MARK: Private helpers
extension Socket {
    private func sendAll(packet: Packet, totalSent: Int, bytesLeft: Int, chunkSize: Int) throws -> Socket {
        if chunkSize == -1 {
            throw SocketError.Send
        } else if bytesLeft == 0 {
            return self
        } else {
            let chunkSize = Foundation.send(Int32(self), packet.bytes+totalSent, bytesLeft, 0)
            return try sendAll(packet, totalSent: totalSent+chunkSize, bytesLeft: bytesLeft-chunkSize, chunkSize: chunkSize)
        }
    }
}

