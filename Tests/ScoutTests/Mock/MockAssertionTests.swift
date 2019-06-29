//
//  MockAssertionTests.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import XCTest

@testable import Scout

class MockAssertionTests : ScoutTestCase {
    func testNoExpectationsDefined() {
        // calling mock.get.strVar since calling mockExample.strVar will crash due to
        // force-unwrapping nil in MockExample.strVar
        captureTestFailure(mockExample.mock.get.strVar as Any?) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("No expectations defined for strVar"))
        }
    }

    func testVerifiesConsumableFuncsAreCalled() {
        mockExample
            .expect
            .nullaryFunc()
            .to(`return`("baz return"))

        assertFails {
            mockExample.assertNoExpectationsRemaining()
        }
    }

    func testDoesNotVerifyPersistentFuncs() {
        mockExample
            .expect
            .nullaryFunc()
            .to(alwaysReturn("baz return"))

        mockExample.assertNoExpectationsRemaining()
    }

    func testAssertNoExpectationsDoesNotAssertWhenEmpty() {
        mockExample.assertNoExpectationsRemaining()
    }

    func testAssertRemainingExpectationsWithOneExpectation() {
        mockExample.expect.strVar.to(`return`("foo"))

        captureTestFailure(mockExample.assertNoExpectationsRemaining())
        { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Remaining expectations"))
        }
    }

    func testAssertRemainingExpectationsWithRemainingValues() {
        mockExample.expect.strVar.to(`return`("foo", times: 2))

        let _ = mockExample.strVar

        assertFails {
            mockExample.assertNoExpectationsRemaining()
        }
    }

    func testAssertRemainingExpectationsIgnoresPersistentExpectations() {
        mockExample.expect.varGetter.to(alwaysReturn("bar"))

        mockExample.assertNoExpectationsRemaining()
    }

    func testAssertRemainingFuncExpectationsWithOneExpectation() {
        mockExample.expect.voidNullaryThows().toBeCalled()

        assertFails {
            mockExample.assertNoExpectationsRemaining()
        }
    }

    func testAssertRemainingFuncExpectationsWithRemainingCall() {
        mockExample.expect.voidNullaryThrows().toBeCalled(times: 2)

        try! mockExample.voidNullaryThrows()

        assertFails {
            mockExample.assertNoExpectationsRemaining()
        }
    }

    func testAssertRemainingFuncCallExpectationsWithRemainingCall() {
        mockExample.expect.voidNullaryThrows().to { _ in
            throw ExampleError()
        }

        assertFails {
            mockExample.assertNoExpectationsRemaining()
        }
    }

    func testAssertRemainingFuncExpectationsIgnorePersistent() {
        mockExample.expect.voidNullaryThrows().toAlways { _ in }

        mockExample.assertNoExpectationsRemaining()
    }
}
