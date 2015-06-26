![Logo](Swocket.png)

[![CI Status](http://img.shields.io/travis/mikoaj/Swocket.svg?style=flat-square)](https://travis-ci.org/mikaoj/Swocket)
[![Version](https://img.shields.io/cocoapods/v/Swocket.svg?style=flat-square)](http://cocoapods.org/pods/Swocket)
[![License](https://img.shields.io/cocoapods/l/Swocket.svg?style=flat-square)](http://cocoapods.org/pods/Swocket)
[![Platform](https://img.shields.io/cocoapods/p/Swocket.svg?style=flat-square)](http://cocoapods.org/pods/Swocket)
## TODO
* UDP

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

##### Echo Client:
```swift
let data = "Wazzzup".dataUsingEncoding(NSUTF8StringEncoding)!

// Set up a socket to localhost on port 9999
let client = Swocket.TCP.init(host: "127.0.0.1", port: 9999)

// Connect to server
client.connectAsync()

// Send message
client.sendDataAsync(data)

// Get response
client.recieveDataAsync({ (data, error) -> Void in
    // Unwrap response as string and set response label
    let response = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
    print(response)
})

// Disconnect
client.disconnectAsync()
```
##### HTTP Server:
```swift
let httpString = "HTTP/1.1 200 OK\nContent-Type: text/html; charset=UTF-8"
let htmlString = "<html><head><title>Hello</title></head><body><h1>Hello World!</h1><p>I am a tiny little web server</p></body></html>"
let data = "\(httpString)\n\n\(htmlString)".dataUsingEncoding(NSUTF8StringEncoding)!

server = try! Swocket.TCP.listen(8080, onConnection: { (client) -> () in
    try! client.recieveData() // Ignore what client requests
    try! client.sendData(data) // And give them the same result every time! :P
})
```
##### Want to things synchronously?
No problem, all async functions have a synchronous counterpart.

##### Handle errors:
```swift
// All async functions have an optional error closure
client.sendDataAsync(data, onError: { (error) -> Void in
  print(error)
})

// And synchronous functions throws an error
do {
  try client.sendData(data)
} catch {
  print(error)
}
```

## Requirements

Xcode 7 (Swift 2)

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
