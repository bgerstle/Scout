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

    func baz() -> String

    var bar: Int { get }

    func biz() throws
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

class ScoutTests: XCTestCase {
    var mockExample: MockExample!
    var assertTestFailureBlock: ((String) -> Void)! = nil

    override func setUp() {
        mockExample = MockExample()
        continueAfterFailure = false
        assertTestFailureBlock = nil
    }

    override func tearDown() {
        mockExample = nil
    }

    override func recordFailure(withDescription description: String,
                                inFile filePath: String,
                                atLine lineNumber: Int,
                                expected: Bool) {
        if let block = assertTestFailureBlock {
            assertTestFailureBlock = nil
            block(description)
        } else {
            super.recordFailure(withDescription: description,
                                inFile: filePath,
                                atLine: lineNumber,
                                expected: expected)
        }
    }

    func captureTestFailure<T>(_ expression: @autoclosure () -> T,
                            _ assertion: @escaping (String) -> Void) {
        assertTestFailureBlock = assertion
        let _ = expression()
    }

    func testReturningVarForMember() {
        mockExample
            .expect.foo
            .to(return: "bar")
            .and.to(return: "baz")

        XCTAssertEqual(mockExample.foo, "bar")
        XCTAssertEqual(mockExample.foo, "baz")
    }

    func testReturningValuesFromSequence() {
        let range = Array(0..<5)
        mockExample.expect.bar.to(returnValuesFrom: range)

        XCTAssertEqual(range.map { _ in mockExample.bar }, [0,1,2,3,4])
    }

    func testReturningValueFromFunctionCall() {
        mockExample.expect.baz().to(return: "baz return")
        XCTAssertEqual(mockExample.baz(), "baz return")
    }

    func testWrongNumberOfArgs() {
        mockExample.expect.baz(any()).to(return: "baz return")

        captureTestFailure(mockExample.baz()) { failureDescription in
            XCTAssert(failureDescription.contains("Expected 1 arguments, but got 0"))
        }
    }

    func testArgMatchFailure() {
        mockExample.expect.buz(equalTo(0)).toBeCalled()

        captureTestFailure(mockExample.buz(1)) { failureDescription in
            XCTAssert(failureDescription.contains("Arguments to buz didn't match"))
        }
    }

    func testPredicateMatcher() {
        mockExample.expect.buz(satisfies { arg in
            guard let i = arg as? Int else {
                return false
            }
            return i % 2 == 0
        }).toBeCalled(times: 2)

        mockExample.buz(2)
        captureTestFailure(mockExample.buz(1)) { failureDesription in
            XCTAssert(failureDesription.contains("Arguments to buz didn't match"))
            XCTAssert(failureDesription.contains("Matching predicate"))
        }
    }

    func testFuncThrows() {
        mockExample.expect.biz().toCall { _ in
            throw ExampleError()
        }

        XCTAssertThrowsError(try mockExample.biz(), "Throws example error") { error in
            XCTAssertTrue(error is ExampleError)
        }
    }
}
