//
//  ExpectFuncTests.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import XCTest

@testable import Scout

class ExpectFuncTests : ScoutTestCase {
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

    func testFuncThrows() {
        mockExample.expect.voidNullaryThrows().to(throwExampleError)

        XCTAssertThrowsError(try mockExample.voidNullaryThrows(), "Throws example error") { error in
            XCTAssertTrue(error is ExampleError)
        }
    }

    func testKeywordFunc() {
        mockExample
            .expect
            .voidMixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1))
            .toBeCalled()

        mockExample.voidMixedKwPosArgs(kwarg: "foo", 1)
    }

    func testKeywordFuncReturns() {
        mockExample
            .expect
            .mixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1))
            .to(`return`("foo"))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")
    }

    func testKeywordFuncReturnsOnlyTwice() {
        mockExample
            .expect
            .mixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1))
            .to(`return`("foo", times: 2))

        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")
        XCTAssertEqual(mockExample.mixedKwPosArgs(kwarg: "foo", 1), "foo")

        // only retrieve the member but don't call,
        // since a fatalError will occur after failure is recorded
        captureTestFailure(mockExample.mixedKwPosArgs(kwarg: "foo", 1)) { (failureDescription, _, _) in
            XCTAssert(failureDescription.contains("No more expectations defined for mixedKwPosArgs"))
        }
    }

    func testKeywordFuncAlwaysReturns() {
        mockExample
            .expect
            .mixedKwPosArgs(kwarg: equalTo("foo"), equalTo(1))
            .to(alwaysReturn("foo"))

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

    func testAlwaysCallFunc() {
        var x = 0
        func incrementX(_ args: KeyValuePairs<String, Any?>) -> String {
            x += 1
            return String(x)
        }
        mockExample.expect.nullaryFunc().toAlways(incrementX)

        XCTAssertEqual("1", mockExample.nullaryFunc())
        XCTAssertEqual("2", mockExample.nullaryFunc())
    }

    func testUnaryThrowsCallsBlock() {
        mockExample.expect.unaryThrows(arg: any()).to({ args in
            XCTAssertEqual(args.first?.value as? String, "one")
        })

        try! mockExample.unaryThrows(arg: "one")

        mockExample.mock.verify()
    }
}
