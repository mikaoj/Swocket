// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
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

/// Packet struct
public struct Packet {
    private var data: NSMutableData

    /// Initializes the Packet with given data
    public init(_ data: NSData = NSData()) {
        self.data = NSMutableData(data: data)
    }
}

extension Packet {
    /// The number of bytes in this Packet
    public var length: Int { return data.length }

    /// The bytes in this Packet
    public var bytes: UnsafePointer<Void> { return data.bytes }
}

extension Packet {
    private var mutableData: NSMutableData {
        mutating get {
            if !isUniquelyReferencedNonObjC(&data) {
                data = mutableData.mutableCopy() as! NSMutableData
            }

            return data
        }
    }

    /// Append data to this Packet
    public mutating func append(other: NSData) {
        mutableData.appendData(other)
    }
}
