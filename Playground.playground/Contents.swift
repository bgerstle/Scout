import Foundation

import Scout

protocol Example {
    var foo: String { get }

    func baz() -> String

    var bar: Int { get }

    func biz() throws

    func buz(_ value: Int)
}

struct ExampleError : Error {

}

class MockExample : Example, Mockable {
    let mock = Mock()

    var foo: String {
        get {
            return mock.get.foo
        }
    }

    var bar: Int {
        get {
            return mock.get.bar
        }
    }

    func baz() -> String {
        return try! mock.call.baz() as! String
    }

    func buz(_ value: Int) {
        try! mock.call.buz(value)
    }

    func biz() throws {
        try mock.call.biz()
    }
}

var mockExample = MockExample()

mockExample
    .expect.foo
    .to(return: "bar")
    .and.to(return: "baz")

mockExample.foo
mockExample.foo

let range = Array(0..<5)
mockExample.expect.bar.to(returnValuesFrom: range)

range.map { _ in mockExample.bar }

mockExample.expect.buz(equalTo(0)).toCall { args in
    print("Hello \(String(describing: args.first))!")
}

mockExample.buz(0)

struct SomeError: Error { }
do {
    mockExample.expect.biz().toCall { _ in throw SomeError() }
    try mockExample.biz()
} catch let error {
    print("Caught \(error)")
}
