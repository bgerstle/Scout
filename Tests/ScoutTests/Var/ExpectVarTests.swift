//
//  ExpectVarTests.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import Foundation

import XCTest

@testable import Scout

class ExpectVarTests : ScoutTestCase {
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

    func testGettingVarForMember() {
        mockExample
            .expect
            .varGetter
            .to(get { 0 })

        XCTAssertEqual(mockExample.varGetter, 0)
    }

    func testWrongReturnType() {
        mockExample
            .expect
            .varGetter
            .to(get { "wrong type" })

        captureTestFailure(mockExample.varGetter) { (failureDescription, _, _) in
            let start = failureDescription.index(failureDescription.startIndex,
                                                 offsetBy: "failed - ".count),
                errorMessage = failureDescription[start ..< failureDescription.endIndex]
            XCTAssertEqual(errorMessage, "Expected value of type Int for varGetter, got String")
        }
    }
}
