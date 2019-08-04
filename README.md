# Scout
Easier, dynamic mocking for Swift.

[![Build Status](https://travis-ci.com/bgerstle/Scout.svg?branch=master)](https://travis-ci.com/bgerstle/Scout) [![codecov](https://codecov.io/gh/bgerstle/Scout/branch/master/graph/badge.svg)](https://codecov.io/gh/bgerstle/Scout)

## Why Scout?
Let's say we have a `TestSubject` that depends on the `Example` protocol.

```swift
protocol Example {
    var foo: String { get }

    func baz()
}

class TestSubject {
    let example: Example

    init(example: Example) {
        self.example = example
    }

    func doAThing() {
        if example.foo == "baz" {
            example.baz()
        }
    }
}
```

If you've done unit testing in Swift, you're probably all to familiar with this dance:

```swift
class ManualMockExample: Example {
    var foo: String

    var bazWasCalled: Bool = false

    init(foo: String) {
        self.foo = foo
    }

    func baz() {
        bazWasCalled = true
    }
}

class ManualMockExampleTests : XCTestCase {
    func testBoilerplateIsTedious() {
        let manualMock = ManualMockExample(foo: "baz")
        let testSubject = TestSubject(example: manualMock)

        testSubject.doAThing()

        XCTAssertTrue(manualMock.bazWasCalled)
    }
}
```

These `<func>WasCalled`  flags and `var` stubs are essentially duplicated in every single mock you write. If you need to throw an exception, invoke a completion block, or anything more complicated, your mocks get even more convoluted. Making matters worse, none of this "mock functionality" is easy to reuse in your tests.

Scout aims to remove all of this boilerplate, and in doing so, make tests easier to both read and write. This is done using a declarative, functional, and dynamic API for creating and configuring mocks. 

## Requirements
- Swift 5 or greater

## Installing
### Swift Package
Add this repo to your package's `dependencies`, similar to this repo's [Example project manifest](/ExampleProject/Package.swift).

### Carthage
There's a [workaround](https://fuller.li/posts/using-swift-package-manager-with-carthage/) for integrating Swift packages using Carthage. TL;DR;

- Add the project to your Cartfile
- Use Carthage to checkout the project
- Generate Scout's Xcode project: `cd Carthage/Checkouts/Scout && swift package generate-xcodeproj`
- Follow [Carthage's instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to integrate Scout into your project

## Getting Started
I recommend starting with `Scout.playground` for a narrative, interactive guide. See [Usage](#usage) for code examples and API documentation.

## Usage
### `Mock`
`Mock` is the entry point for all other APIs. It's meant to be embedded in a protocol-conformant mock class, like so:

```swift
protocol Example {
    var foo: String { get }

    func baz()
}

class MockExample : Example, Mockable {
    let mock = Mock()
    
    var foo: String {
        get {
            return mock.get.foo
        }
    }
    
    func baz() {
        try! mock.call.baz()
    }
}
```

This example demonstrates the two APIs meant for use within a mock class:

### `Mock#get`
Returns a [`@dynamicMemberLookup`](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID585) proxy that retrieves the next expectation for the `var` that's accessed. For example, to get the next expectation for the var `foo`: 

```swift
protocol GetExample {
    var foo: String
}
class MockGetExample : GetExample, Mockable {
    let mock = Mock()
    
    var foo: String {
        get {
            return mock.get.foo
        }
    }
}
```

The dynamic member proxy is generic, meaning it uses type inference to determine that `foo` should be a `String`. 

### `Mock#call`
Returns a [`@dynamicCallable`](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID603) proxy that will retrieve an expectation for the called function. 

```swift
protocol CallExample {
    func baz(buz: Int) -> Int
}
class MockCallExample : CallExample, Mockable {
    let mock = Mock()

    func baz(buz: Int) {
        return try! mock.call.baz(buz: buz) as! Int
    }
}
```
Make sure you pass all arguments from the wrapper class to the `Mock`.

> Since `call` is declared as `throws` (to support expecting an error), you'll need to add `try!` if it's being used in a function that isn't declared  `throws`. 

> As of Swift 5, `call` can't be made generic. Until Swift supports generic `@dynamicCallable` types, you'll need to force-cast from `Any?` to the expected return type. 

### `Mock#expect`
Returns a dynamic DSL object which configures the behavior of calls to `mock.get.<var>` and `mock.call.<func>`.

#### Expecting Var Gets
Simply access the desired `var`, then call `to` with the desired expectation:

```swift
mockGetExample.expect.foo.to(`return`("baz"))
mockGetExample.foo // returns "baz"
```

If there aren't any expectations when `foo` is called, `Mock` will fail the test. If there are still expectations left when `verify()` is called, `Mock` will fail the test.

#### Expecting Function Calls
Similar to `var` expectations, call the desired function, followed by `.to()` with the desired expectation as an argument:

```swift
mockCallExample.expect.baz(buz: equalTo(3)).to(`return`(4))
mockCallExample.baz(3) // returns 4
```

If `baz` was called with something other than `3`, `Mock` would have failed the test. Also, if `baz` is called when no calls were expected, `Mock` will fail the test. As shown above, you'll need to specify an `ArgMatcher` when expecting a call to a function with arguments.

##### Expecting Function Arguments
See [`ArgMatcher`](/Sources/Scout/Expect/ArgMatcher.swift) for a list of available argument matchers. The two simplest are:

`equalTo(value)`: checks that the argument is equal to the specified value.

`any()`: accepts any argument.

If an argument fails to satisfy the specified matcher, `Mock` will fail the test.

### Expectations
Once you've retrieved a `var` or called a function on `expect`, you need to set an expectation using the `to()` method:

```swift
mockCallExample.expect.baz(buz: equalTo(3)).to(`return`(4))
```

In this case, the expectation is to "return 4." What you can expect varies based on whether you're expecting a `var` or function call:

#### Var Expectations
[`ExpectVarDSL`](/Sources/Scout/Expect/ExpectVarDSL.swift) is used to expose the expectation DSL for `var` access. The `to` method only takes one form, and it accepts [`Expectation`](/Sources/Scout/Expect/ExpectVarDSL.swift) instances returned by any of the factory functions:

- ``return``: Return a single value one or more times (aliased as `returnValue` for the backtick averse).
- `alwaysReturn`: Like ``return``, but always.
- `get`: Return a value from a closure.


#### Function Expectations
[`ExpectFuncDSL`](/Sources/Scout/Expect/ExpectFuncDSL.swift) provides the expectation-setting DSL for function calls. It has two different signatures:

One similar to var expectations: 

```swift
mockExample.to(`return`("foo"))
```

And another that's functional:

```swift
func incrementBy(_ amount: Int) -> FuncExpectationBlock {
    return { args in
        return args.first as! Int + amount
    }
}
mockExample.expect.foo.to(incrementBy(1))
```

The functional one is useful when you have more advanced behaviors to expect, like [calling a completion block](/ExampleProject/Tests/ExampleProjectTests/DataLoadable/DataLoadableResultAdapterTests.swift#L38-L43).

Once you've set expectations on your mock, you'll need to verify that they're met.

### `Mock#verify`
At the bottom of a test method, you should call `verify()` on your mock class if you want to assert that all of its expectations were met.

```swift
func testCallsBazIfFooIsBaz() {
    mockExample.expect.foo.to(`return`("baz"))
    mockExample.expect.baz().toBeCalled()

    bazFunc(mockExample)

    mockExample.verify()
}
```
In this example, the test will fail if  `bazFunc` doesn't call `mockExample.baz()`.

> Any expectations added using `toAlways` won't fail the test if they aren't called.

### `Mockable`
Once you've set up a `Mockable` class, you can use some of `Mock`'s methods on it courtesy of the [protocol extension](/Sources/Scout/Mock/Mockable.swift#L15) which exposes some methods of `Mock` on the class it's embedded in for convenience. This prevents you from having to type `.mock.expect...` in all your tests.


## Caveats
Tests using mocks with Scout should set `continueAfterFailure` to `false`, otherwise the tests could crash due to unwrapping an unexpected `nil` error.

There are a few things that `@dynamicCallable` can't do:

- Generic return types. Workaround is to use `Any` and force-cast.
- `inout` parameters. Workaround is to declare your mock class using `inout` and do a non-`inout` call on the mock (see [ExampleProject tests](/ExampleProject/Tests/ExampleProjectTests/Caretaker/CaretakerMocks.swift#L18-L28) for an example).
