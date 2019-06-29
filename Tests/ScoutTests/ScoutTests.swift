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

    func testAssertRemainingFuncExpectationsIgnorePersistent() {
        mockExample.expect.voidNullaryThrows().toAlways { _ in }

        mockExample.mock.assertNoExpectationsRemaining()
    }
}
