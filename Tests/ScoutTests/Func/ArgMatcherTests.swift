//
//  ArgMatcherTests.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import XCTest

@testable import Scout

class ArgMatcherTests : ScoutTestCase {
    func testWrongNumberOfArgs() {
        mockExample.expect.nullaryFunc(any()).to(`return`("baz return"))

        captureTestFailure(mockExample.nullaryFunc()) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("Expected 1 arguments, but got 0"))
        }
    }

    func testPositionalArgMatchFailure() {
        let (expectedLocation, _) =
            runAndGetLocation(mockExample.expect.voidPositional(equalTo(0)).toBeCalled())

        assertFails(withMessage:
                        """
                        failed - Arguments to voidPositional didn't match:
                          - [0]: Expected argument equal to 0, got 1
                        """,
                    inFile: expectedLocation.file,
                    atLine: expectedLocation.line) {
                        mockExample.voidPositional(1)
        }
    }

    func testMixedKwPositionalArgMatchFailure() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .mixedKwPosArgs(kwarg: equalTo("foo"),
                                    equalTo(-1))
                    .to(`return`("bar")))

        assertFails(withMessage:
                        """
                        failed - Arguments to mixedKwPosArgs didn't match:
                          - kwarg: Expected argument equal to foo, got bar
                          - [1]: Expected argument equal to -1, got 1
                        """,
                    inFile: expectedLocation.file,
                    atLine: expectedLocation.line) {
            mockExample.mixedKwPosArgs(kwarg: "bar", 1)
        }
    }

    func testPartialArgMatchFailurePositional() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .mixedKwPosArgs(kwarg: equalTo("foo"),
                                    equalTo(-1))
                    .to(`return`("bar")))

        assertFails(withMessage:
                        """
                        failed - Arguments to mixedKwPosArgs didn't match:
                          - [1]: Expected argument equal to -1, got 1
                        """,
                    inFile: expectedLocation.file,
                    atLine: expectedLocation.line) {
                        mockExample.mixedKwPosArgs(kwarg: "foo", 1)
        }
    }

    func testPartialArgMatchFailureKeyword() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .mixedKwPosArgs(kwarg: equalTo("foo"),
                                    equalTo(-1))
                    .to(`return`("bar")))

        assertFails(withMessage:
                        """
                        failed - Arguments to mixedKwPosArgs didn't match:
                          - kwarg: Expected argument equal to foo, got bar
                        """,
                    inFile: expectedLocation.file,
                    atLine: expectedLocation.line) {
                        mockExample.mixedKwPosArgs(kwarg: "bar", -1)
        }
    }

    func testKeywordMatchFailure() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .mixedKwPosArgs(wrongKeyword: equalTo("foo"),
                                    equalTo(-1))
                    .to(`return`("bar")))

        assertFails(withMessage:
                        """
                        failed - Expected call with keywords ["wrongKeyword", ""], got ["kwarg", ""].
                        """,
                    inFile: expectedLocation.file,
                    atLine: expectedLocation.line) {
                        mockExample.mixedKwPosArgs(kwarg: "foo", -1)
        }
    }

    func testPredicateMatcher() {
        let (expectedLocation, _) =
            runAndGetLocation(
                mockExample
                    .expect
                    .voidPositional(satisfying("is even") { arg in
                        guard let i = arg as? Int else {
                            return false
                        }
                        return i % 2 == 0
                    })
                    .toBeCalled(times: 2))

        mockExample.voidPositional(2)

        captureTestFailure(mockExample.voidPositional(1)) { (failureDescription, file, line) in
            XCTAssert(failureDescription.contains("Arguments to voidPositional didn't match"))
            XCTAssert(failureDescription.contains("is even"))
            XCTAssertEqual(expectedLocation.file, file)
            XCTAssertEqual(expectedLocation.line, line)
        }
    }

    func testAnyMatcher() {
        mockExample
            .expect
            .mixedKwPosArgs(kwarg: any(), any())
            .to(alwaysReturn("foo"))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "bar", -1), "foo")
        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "baz", 1), "foo")
    }

    func testMatchesNil() {
        mockExample
            .expect
            .optionalArg(`nil`)
            .toBeCalled()

        mockExample.optionalArg(nil)
    }

    func testNilMatcherFailsForNonNil() {
        mockExample
            .expect
            .optionalArg(`nil`)
            .toBeCalled()

        assertFails {
            mockExample.optionalArg(1)
        }
    }

    func testEqualityMatcherFailsForNil() {
        mockExample
            .expect
            .optionalArg(equalTo(1))
            .toBeCalled()

        assertFails {
            mockExample.optionalArg(nil)
        }
    }
}
