//
//  Mockable.swift
//  Scout
//
//  Created by Brian Gerstle on 6/29/19.
//

import Foundation

// Sugar which adds expect & assert DSLs to any class that has an embedded mock.
public protocol Mockable {
    var mock: Mock { get }
}

public extension Mockable {
    var expect: ExpectDSL {
        return ExpectDSL(mock: mock)
    }

    func assertNoExpectationsRemaining(file: StaticString = #file,
                                       line: UInt = #line) {
        mock.assertNoExpectationsRemaining(file: file, line: line)
    }
}
