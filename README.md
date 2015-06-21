![Logo](Swocket.png)

[![CI Status](http://img.shields.io/travis/Joakim Gyllstrom/Swocket.svg?style=flat)](https://travis-ci.org/Joakim Gyllstrom/Swocket)
[![Version](https://img.shields.io/cocoapods/v/Swocket.svg?style=flat)](http://cocoapods.org/pods/Swocket)
[![License](https://img.shields.io/cocoapods/l/Swocket.svg?style=flat)](http://cocoapods.org/pods/Swocket)
[![Platform](https://img.shields.io/cocoapods/p/Swocket.svg?style=flat)](http://cocoapods.org/pods/Swocket)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

##### Client:
```swift

```
##### Server:
```swift
let data = "Hello world!\n".dataUsingEncoding(NSUTF8StringEncoding)!

Swocket.listen(1337, onConnection: { (client) -> () in
    client.send(data)
})
```

## Requirements

Xcode 7

## Installation

Swocket is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Swocket"
```

## Author

Joakim Gyllström, joakim@backslashed.se

## License

Swocket is available under the MIT license. See the LICENSE file for more info.
