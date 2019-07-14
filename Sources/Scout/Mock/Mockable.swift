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
        return mock.expect
    }

    func verify(file: StaticString = #file,
                                       line: UInt = #line) {
        mock.verify(file: file, line: line)
    }
}
