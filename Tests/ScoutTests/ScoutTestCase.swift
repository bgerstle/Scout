//
//  ScoutTestCase.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import Foundation
import XCTest

class ScoutTestCase: XCTestCase {
    var mockExample: MockExample!
    // For some reason, XCTFail takes StaticString & UInt, but recordFailure takes String & Int.
    // Probably "because Objective-C"
    var assertTestFailureBlock: ((String, String, Int) -> Void)! = nil

    override func setUp() {
        mockExample = MockExample()
        continueAfterFailure = false
        assertTestFailureBlock = nil
    }

    override func tearDown() {
        XCTAssert(assertTestFailureBlock == nil, "Expected test failure which did not occur")
        mockExample = nil
    }

    override func recordFailure(
        withDescription description: String,
                                inFile filePath: String,
                                atLine lineNumber: Int,
                                expected: Bool) {
        if let block = assertTestFailureBlock {
            assertTestFailureBlock = nil
            block(description, filePath, lineNumber)
        } else {
            super.recordFailure(withDescription: description,
                                inFile: filePath,
                                atLine: lineNumber,
                                expected: expected)
        }
    }

    func captureTestFailure<T>(_ expression: @autoclosure () -> T,
                               _ assertion: @escaping (String, String, Int) -> Void) {
        assertTestFailureBlock = assertion
        let _ = expression()
    }
}
