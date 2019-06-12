//
//  MockFailure.swift
//  Scout
//
//  Created by Brian Gerstle on 6/12/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

import XCTest

internal func recordFailure(_ message: String) {
    XCTFail(message)
}

internal func fail(unless condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        recordFailure(message)
    }
}
