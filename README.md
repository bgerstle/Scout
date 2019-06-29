# Scout
Dynamic mocking for Swift.

[![Build Status](https://travis-ci.com/bgerstle/Scout.svg?branch=master)](https://travis-ci.com/bgerstle/Scout)

> Requires Swift 5 and above

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
