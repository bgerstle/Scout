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

var mf = MockExample()

mf.expect
    .foo
    .toReturn("bar")
    .and.toReturn("baz")

mf.foo
mf.foo

let range = Array(0..<5)
mf.expect.bar.toReturn(valuesFrom: range)

range.map { _ in mf.bar }
