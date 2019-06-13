# Scout
Dynamic mocking for Swift.

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
        return mock.call.baz() as! String
    }
}
```

And stub some return values:

```swift
var mockExample = MockExample()

mockExample
    .expect.foo
    .to(return: "bar")

mockExample.foo // "bar"

mockExample.expect.baz().to(return: "buz")

mockExample.baz() // "buz"
```

See the Playground for more examples.

## How It Works
This uses the new `dynamicMember` and `dynamicCallable` language features added in Swift 4.2 and 5. These dynamic methods drastically reduce the amount of boilerplate mocking code you need to write while also eliminating stringly-typed dynamic mocks.

