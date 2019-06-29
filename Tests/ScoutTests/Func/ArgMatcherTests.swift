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

    func testAnyMatcher() {
        mockExample
            .expect
            .mixedKwPosArgs(kwarg: any(), any())
            .to(alwaysReturn("foo"))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "bar", -1), "foo")
        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "baz", 1), "foo")
    }
}
