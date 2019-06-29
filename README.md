# Scout
Dynamic mocking for Swift.

<span>
[![Build Status](https://travis-ci.com/bgerstle/Scout.svg?branch=master)](https://travis-ci.com/bgerstle/Scout)
[![codecov](https://codecov.io/gh/bgerstle/Scout/branch/master/graph/badge.svg)](https://codecov.io/gh/bgerstle/Scout)
</span>

## Requirements
- Swift 5 or greater

## Quick Example
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

mockExample.expect.baz().to(`return("buz"))

mockExample.baz() // "buz"
```

See the Playground for more examples.
