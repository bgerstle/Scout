//
//  ScoutTests.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import XCTest
@testable import Scout
protocol Example {
    var foo: String { get }
    var bar: Int { get }

    func baz() -> String
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

    func baz() -> String {
        // FIXME: this casting as fuuuuugly. maybe some DSL like mock.call to enter dynamicCallable
        // with a templated return type?
        return (mock.baz as ([Any?]) -> Any?)([]) as! String
    }
}

class ScoutTests: XCTestCase {
    var mockExample: MockExample!

    override func setUp() {
        mockExample = MockExample()
    }

    override func tearDown() {
        mockExample = nil
    }

    func testReturningVarForMember() {
        mockExample.expect
            .foo
            .toReturn("bar")
            .and.toReturn("baz")

        XCTAssertEqual(mockExample.foo, "bar")
        XCTAssertEqual(mockExample.foo, "baz")
    }

    func testReturningValuesFromSequence() {
        let range = Array(0..<5)
        mockExample.expect.bar.toReturn(valuesFrom: range)

        XCTAssertEqual(range.map { _ in mockExample.bar }, [0,1,2,3,4])
    }

    func testReturningValueFromFunctionCall() {
        mockExample.expect.baz().andDo { _ in "baz return" }
        XCTAssertEqual(mockExample.baz(), "baz return")

    }
}
