//
//  ScoutTestCase.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import Foundation
import XCTest

struct TestFailureAssertion {
    typealias Assertion = ((String, String, Int) -> Void)
    let block: Assertion
    let file: StaticString
    let line: UInt
}

class ScoutTestCase: XCTestCase {
    var mockExample: MockExample!
    // For some reason, XCTFail takes StaticString & UInt, but recordFailure takes String & Int.
    // Probably "because Objective-C"
    private var failureAssertion: TestFailureAssertion! = nil

    override func setUp() {
        mockExample = MockExample()
        continueAfterFailure = false
        failureAssertion = nil
    }

    override func tearDown() {
        if let failureAssertion = failureAssertion {
            self.failureAssertion = nil
            XCTFail("Expected test failure to be recorded, but nothing happened.",
                    file: failureAssertion.file,
                    line: failureAssertion.line)
        }
        mockExample = nil
    }

    override func recordFailure(
        withDescription description: String,
                                inFile filePath: String,
                                atLine lineNumber: Int,
                                expected: Bool) {
        if let failureAssertion = failureAssertion {
            self.failureAssertion = nil
            failureAssertion.block(description, filePath, lineNumber)
        } else {
            super.recordFailure(withDescription: description,
                                inFile: filePath,
                                atLine: lineNumber,
                                expected: expected)
        }
    }

    func assertFails<T>(
        withMessage expectedMessage: String? = nil,
        inFile expectedFile: String? = nil,
        atLine expectedLine: Int? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        _ expression: () -> T
    ) {
        failureAssertion = TestFailureAssertion(block: { (actualMessage, actualFile, actualLine) in
            if let expectedMessage = expectedMessage {
                XCTAssertEqual(expectedMessage, actualMessage, file: file, line: line)
            }
            if let expectedFile = expectedFile {
                XCTAssertEqual(expectedFile, actualFile, file: file, line: line)
            }
            if let expectedLine = expectedLine {
                XCTAssertEqual(expectedLine, actualLine, file: file, line: line)
            }
        }, file: file, line: line)
        let _ = expression()
    }

    func captureTestFailure<T>(_ expression: @autoclosure () -> T,
                               file: StaticString = #file,
                               line: UInt = #line,
                               _ assertion: @escaping (String, String, Int) -> Void) {
        failureAssertion = TestFailureAssertion(block: assertion, file: file, line: line)
        let _ = expression()
    }
}
