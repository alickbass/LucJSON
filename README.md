# LucJSON
Luc JSON is a library that uses [JSONSerialization's](https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSJSONSerialization.swift) implementation, but replaces all the `Any` and uses `JSON` type.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![codecov](https://codecov.io/gh/alickbass/LucJSON/branch/master/graph/badge.svg)](https://codecov.io/gh/alickbass/LucJSON)
[![Build Status](https://travis-ci.org/alickbass/LucJSON.svg?branch=master)](https://travis-ci.org/alickbass/LucJSON)

## Why remove Any?

The fact that `JSONSerialization` returns `Any` is the biggest lie ever, as [JSON](http://www.json.org) defines explicitly what can be represented as `JSON` and what cannot. That is why `JSON` in this library is the following `enum`:

```swift
enum JSON {
    case null
    case number(NSNumber)
    case bool(Bool)
    case string(String)
    case object([String: JSON])
    case array([JSON])
}
```

**Moreover, there is also performance implications when using `Any`**:

Whenever you do the following:

```swift
let json: Any = //JSON from the JSONSerialization
let object: [String: Any]? = json as? [String: Any]
```

It has to go through the whole object, to make sure that all the keys are `String`. Which is `O(n)` time complexity where `n` is the number of keys in the `JSON` object.

In the `LucJSON` we achieve with the following code:

```swift
let json: JSON = //JSON from the JSON.Serialization
let object: [String: JSON]? = json.object
```

As the `JSON` is `enum` it is now accomplished with a regular case check and there is no need to go through all the keys, as the keys can only be `String` in the `enum`
