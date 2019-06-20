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
    var strVar: String { get }

    func nullaryFunc() -> String

    var varGetter: Int { get }

    func voidNullaryThrows() throws

    func voidPositional(_ value: Int)

    func voidMixedKwPosArgs(kwarg: String, _ posValue: Int)
}

struct ExampleError : Error {

}

class MockExample : Example, Mockable {
    let mock = Mock()

    var strVar: String {
        get {
            return mock.get.strVar
        }
    }

    var varGetter: Int {
        get {
            return mock.get.varGetter
        }
    }

    func nullaryFunc() -> String {
        return try! mock.call.nullaryFunc() as! String
    }

    func voidPositional(_ value: Int) {
        try! mock.call.voidPositional(value)
    }

    func voidNullaryThrows() throws {
        try mock.call.voidNullaryThrows()
    }

    func voidMixedKwPosArgs(kwarg: String, _ posValue: Int) {
        try! mock.call.voidMixedKwPosArgs(kwarg: kwarg, posValue)
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
            .expect.strVar
            .to(return: "bar")
            .and.to(return: "baz")

        XCTAssertEqual(mockExample.strVar, "bar")
        XCTAssertEqual(mockExample.strVar, "baz")
    }

    func testReturningValuesFromSequence() {
        let range = Array(0..<5)
        mockExample.expect.varGetter.to(returnValuesFrom: range)

        XCTAssertEqual(range.map { _ in mockExample.varGetter }, [0,1,2,3,4])
    }

    func testReturningValueFromFunctionCall() {
        mockExample.expect.nullaryFunc().to(return: "baz return")
        XCTAssertEqual(mockExample.nullaryFunc(), "baz return")
    }

    func testWrongNumberOfArgs() {
        mockExample.expect.nullaryFunc(any()).to(return: "baz return")

        captureTestFailure(mockExample.nullaryFunc()) { failureDescription in
            XCTAssert(failureDescription.contains("Expected 1 arguments, but got 0"))
        }
    }

    func testArgMatchFailure() {
        mockExample.expect.voidPositional(equalTo(0)).toBeCalled()

        captureTestFailure(mockExample.voidPositional(1)) { failureDescription in
            XCTAssert(failureDescription.contains("Arguments to voidPositional didn't match"))
        }
    }

    func testPredicateMatcher() {
        mockExample.expect.voidPositional(satisfies { arg in
            guard let i = arg as? Int else {
                return false
            }
            return i % 2 == 0
        }).toBeCalled(times: 2)

        mockExample.voidPositional(2)

        captureTestFailure(mockExample.voidPositional(1)) { failureDesription in
            XCTAssert(failureDesription.contains("Arguments to voidPositional didn't match"))
            XCTAssert(failureDesription.contains("Matching predicate"))
        }
    }

    func testFuncThrows() {
        mockExample.expect.voidNullaryThrows().toCall { _ in
            throw ExampleError()
        }

        XCTAssertThrowsError(try mockExample.voidNullaryThrows(), "Throws example error") { error in
            XCTAssertTrue(error is ExampleError)
        }
    }

    func testKeywordFunc() {
        mockExample.expect.voidMixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1)).toBeCalled()

        mockExample.voidMixedKwPosArgs(kwarg: "foo", 1)
    }
}
