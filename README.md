# Scout
Dynamic mocking for Swift.

[![Build Status](https://travis-ci.com/bgerstle/Scout.svg?branch=master)](https://travis-ci.com/bgerstle/Scout) [![codecov](https://codecov.io/gh/bgerstle/Scout/branch/master/graph/badge.svg)](https://codecov.io/gh/bgerstle/Scout)

## Requirements
- Swift 5 or greater

## Installing
### Swift Package
Add this repo to your package's `dependencies`, similar to this repo's [Example project manifest](/ExampleProject/Package.swift).

### Carthage
There's a [workaround](https://fuller.li/posts/using-swift-package-manager-with-carthage/) for integration Swift packages using Carthage. TL;DR;

- Add the project to your Cartfile
- Use Carthage to checkout the project
- Generate Scout's Xcode project: `cd Carthage/Checkouts/Scout && swift package generate-xcodeproj`
- Follow [Carthage's instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to integrate Scout into your project

## Getting Started
Let's create a mock for an example interface:

```swift
import Scout

protocol Example {
    var foo: String { get }

    func baz() -> String
}

class MockExample : Example, Mockable {
    let mock = Mock()

    var foo: String {
        get {
            return mock.get.foo
        }
    }

    func baz() -> String {
        return try! mock.call.baz() as! String
    }
}
```

And stub some return values:

```swift
var mockExample = MockExample()

mockExample.expect.foo.to(`return`("bar"))

mockExample.foo // "bar"

mockExample.expect.baz().to(`return`("buz"))

mockExample.baz() // "buz"
```

See the Playground for more examples.
