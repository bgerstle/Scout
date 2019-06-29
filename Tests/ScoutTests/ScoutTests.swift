//
//  ScoutTests.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import XCTest

@testable import Scout

class ScoutTests: ScoutTestCase {
    func testNoExpectationsDefined() {
        // calling mock.get.strVar since calling mockExample.strVar will crash due to
        // force-unwrapping nil in MockExample.strVar
        captureTestFailure(mockExample.mock.get.strVar as Any?) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("No expectations defined for strVar"))
        }
    }

    func testReturningVarForMemberOnce() {
        mockExample
            .expect
            .strVar
            .to(`return`("bar"))

        XCTAssertEqual(mockExample.strVar, "bar")

        captureTestFailure(mockExample.mock.get.strVar as Any?) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("No more expectations defined for strVar"))
        }
    }

    func testReturningVarForMemberTwice() {
        mockExample
            .expect
            .strVar
            .to(`return`("bar", times: 2))

        XCTAssertEqual(mockExample.strVar, "bar")
        XCTAssertEqual(mockExample.strVar, "bar")

        captureTestFailure(mockExample.mock.get.strVar as Any?) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("No more expectations defined for strVar"))
        }
    }

    func testReturningVarForMember() {
        mockExample
            .expect
            .strVar
            .to(`return`("bar"))
            .and
            .to(`return`("baz"))

        XCTAssertEqual(mockExample.strVar, "bar")
        XCTAssertEqual(mockExample.strVar, "baz")
    }

    func testNullaryFunc() {
        mockExample
            .expect
            .nullaryFunc()
            .to(`return`("baz return"))
            .and
            .to(`return`("buz"))
        XCTAssertEqual(mockExample.nullaryFunc(), "baz return")
        XCTAssertEqual(mockExample.nullaryFunc(), "buz")
    }

    func testWrongNumberOfArgs() {
        mockExample.expect.nullaryFunc(any()).to(`return`("baz return"))

        captureTestFailure(mockExample.nullaryFunc()) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Expected 1 arguments, but got 0"))
        }
    }

    func testArgMatchFailure() {
        let (expectedLocation, _) =
            runAndGetLocation(mockExample.expect.voidPositional(equalTo(0)).toBeCalled())

        captureTestFailure(mockExample.voidPositional(1)) { (failureDescription, file, line) in
            XCTAssert(failureDescription.contains("Arguments to voidPositional didn't match"))
            XCTAssertEqual(expectedLocation.file, file)
            XCTAssertEqual(expectedLocation.line, line)
        }
    }

    func testPredicateMatcher() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .voidPositional(satisfies { arg in
                        guard let i = arg as? Int else {
                            return false
                        }
                        return i % 2 == 0
                    })
                    .toBeCalled(times: 2))

        mockExample.voidPositional(2)

        captureTestFailure(mockExample.voidPositional(1)) { (failureDescription, file, line) in
            XCTAssert(failureDescription.contains("Arguments to voidPositional didn't match"))
            XCTAssert(failureDescription.contains("Matching predicate"))
            XCTAssertEqual(expectedLocation.file, file)
            XCTAssertEqual(expectedLocation.line, line)
        }
    }

    func testFuncThrows() {
        mockExample.expect.voidNullaryThrows().to { _ in
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

    func testKeywordFuncReturns() {
        mockExample.expect.mixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1)).to(`return`("foo"))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")
    }

    func testKeywordFuncReturnsOnlyTwice() {
        mockExample.expect.mixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1)).to(`return`("foo", times: 2))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")
        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")

        // only retrieve the member but don't call,
        // since a fatalError will occur after failure is recorded
        captureTestFailure(mockExample.mixedKwPosArgs(kwarg: "foo", 1)) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("No more expectations defined for mixedKwPosArgs"))
        }
    }

    func testKeywordFuncAlwaysReturns() {
        mockExample.expect.mixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1)).to(alwaysReturn("foo"))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")
        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")
    }

    func testKeywordFuncFailure() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .voidMixedKwPosArgs(kwarg: equalTo("bar"), equalTo(1))
                    .toBeCalled())

        captureTestFailure(mockExample.voidMixedKwPosArgs(kwarg: "foo", 1))
        { (failureDescription, file, line) in
            XCTAssert(failureDescription.contains("Arguments to voidMixedKwPosArgs didn't match"))
            XCTAssertEqual(expectedLocation.file, file)
            XCTAssertEqual(expectedLocation.line, line)
        }
    }

    func testAssertNoExpectationsDoesNotAssertWhenEmpty() {
        mockExample.mock.assertNoExpectationsRemaining()
    }

    func testAssertRemainingExpectationsWithOneExpectation() {
        mockExample.expect.strVar.to(`return`("foo"))

        captureTestFailure(mockExample.mock.assertNoExpectationsRemaining())
        { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Remaining expectations"))
        }
    }

    func testAssertRemainingExpectationsWithRemainingValues() {
        mockExample.expect.strVar.to(`return`("foo", times: 2))

        let _ = mockExample.strVar

        captureTestFailure(mockExample.mock.assertNoExpectationsRemaining())
        { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Remaining expectations"))
        }
    }

    func testAssertRemainingExpectationsIgnoresPersistentExpectations() {
        mockExample.expect.varGetter.to(alwaysReturn("bar"))

        mockExample.mock.assertNoExpectationsRemaining()
    }

    func testAssertRemainingFuncExpectationsWithOneExpectation() {
        mockExample.expect.voidNullaryThows().toBeCalled()

        captureTestFailure(mockExample.mock.assertNoExpectationsRemaining())
        { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Remaining expectations"))
        }
    }

    func testAssertRemainingFuncExpectationsWithRemainingCall() {
        mockExample.expect.voidNullaryThrows().toBeCalled(times: 2)

        try! mockExample.voidNullaryThrows()

        captureTestFailure(mockExample.mock.assertNoExpectationsRemaining())
        { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Remaining expectations"))
        }
    }

    func testAssertRemainingFuncCallExpectationsWithRemainingCall() {
        mockExample.expect.voidNullaryThrows().to { _ in
            throw ExampleError()
        }

        captureTestFailure(mockExample.mock.assertNoExpectationsRemaining())
        { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Remaining expectations"))
        }
    }

    func testAlwaysCallFunc() {
        var x = 0
        mockExample.expect.nullaryFunc().toAlways { _ in
            x += 1
            return String(x)
        }

        XCTAssertEqual("1", mockExample.nullaryFunc())
        XCTAssertEqual("2", mockExample.nullaryFunc())
    }

    func testAssertRemainingFuncExpectationsIgnorePersistent() {
        mockExample.expect.voidNullaryThrows().toAlways { _ in }

        mockExample.mock.assertNoExpectationsRemaining()
    }

    func testUnaryThrowsCallsBlock() {
        mockExample.expect.unaryThrows(any()).to { args in
            XCTAssertEqual(args.first?.value as? String, "one")
        }

        try! mockExample.unaryThrows(arg: "one")

        mockExample.mock.assertNoExpectationsRemaining()
    }
}
