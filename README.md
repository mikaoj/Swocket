![Logo](Swocket.png)

[![CI Status](http://img.shields.io/travis/Joakim Gyllstrom/Swocket.svg?style=flat)](https://travis-ci.org/Joakim Gyllstrom/Swocket)
[![Version](https://img.shields.io/cocoapods/v/Swocket.svg?style=flat)](http://cocoapods.org/pods/Swocket)
[![License](https://img.shields.io/cocoapods/l/Swocket.svg?style=flat)](http://cocoapods.org/pods/Swocket)
[![Platform](https://img.shields.io/cocoapods/p/Swocket.svg?style=flat)](http://cocoapods.org/pods/Swocket)
## Note
This is not ready for production yet. But I'm hoping to have it ready for the world in a couple of weeks.

## TODO
* UDP
* Tests
* Inline C helper methods
* Benchmark
* Cleanup
* Cocoapods

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

##### Client:
```swift
let data = "Wazzzup".dataUsingEncoding(NSUTF8StringEncoding)!

// Connect to server
client.connect()

// Send message
client.send(data)

// Get response
client.recieve({ (socket, data) -> () in
    // Unwrap response as string and print it
    if let response = String(CString: UnsafePointer<CChar>(data.bytes), encoding: NSUTF8StringEncoding) {
        print(response)
    }
})

// Disconnect
client.disconnect()
```
##### Server:
```swift
let data = "Hello world!\n".dataUsingEncoding(NSUTF8StringEncoding)!

Swocket.listen(1337, onConnection: { (client) -> () in
    client.send(data)
})
```

##### Handle errors:
```swift
// All functions have an optional error closure
Swocket.listen(1337, onConnection: { (client) -> () in
    client.send(data)
}) { (error) -> () in
    print(error)
}
```

## Requirements

Xcode 7

## Installation

Swocket <s>is</s> will be available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Swocket"
```

## Author

Joakim Gyllström, joakim@backslashed.se

## License

Swocket is available under the MIT license. See the LICENSE file for more info.
