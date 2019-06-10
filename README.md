# Scout
Dynamic mocking for Swift.

> Requires Swift 5 and above

## Quick Example
Let's create a mock for an example interface:

```swift
import Scout

protocol Example {
    var foo: String { get }
    var bar: Int { get }
}

class MockExample : Example, Mockable {
    let mock = Mock()

    var foo: String {
        get {
            return mock.foo
        }
    }

    var bar: Int {
        get {
            return mock.bar
        }
    }
}
```

And stub some return values:

```swift
var mockExample = MockExample()

mockExample.expect
    .foo
    .toReturn("bar")
    .and.toReturn("baz")

mockExample.foo // "bar"
mockExample.foo // "baz"

let range = Array(0..<5)
mockExample.expect.bar.toReturn(valuesFrom: range)

range.map { _ in mockExample.bar } // 0, 1, 2, 3, 4
```

## How It Works
This uses the new `dynamicMember and `dynamicCallable` language features added in Swift 4.2 and 5 respectively. These dynamic methods allow the mocking DSL to be much more dynamic while also reducing the amount of boilerplate mocking code you need to write.

