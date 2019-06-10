import Foundation

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

var mockExample = MockExample()

mockExample.expect
    .foo
    .toReturn("bar")
    .and.toReturn("baz")

mockExample.foo
mockExample.foo

let range = Array(0..<5)
mockExample.expect.bar.toReturn(valuesFrom: range)

range.map { _ in mockExample.bar }
