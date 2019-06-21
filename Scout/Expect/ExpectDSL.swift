//
//  ExpectDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/12/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

// Interface for all expectations of a mock.
protocol Expectation: class {
    func hasNext() -> Bool
    func nextValue() -> Any?
}

// DSL for setting expectations on a mock, either as member vars or function calls.
@dynamicMemberLookup
public struct ExpectDSL {
    let mock: Mock

    public subscript(dynamicMember member: String) -> ExpectVarDSL {
        get {
            return ExpectVarDSL(mock: mock, member: member)
        }
    }

    public subscript(dynamicMember member: String) -> ExpectFuncDSL {
        get {
            return ExpectFuncDSL(mock: mock, funcName: member)
        }
    }
}

// Sugar for any test class that has an embedded mock to add the "expect" DSL.
public protocol Mockable {
    var mock: Mock { get }
}

public extension Mockable {
    var expect: ExpectDSL {
        return ExpectDSL(mock: mock)
    }
}
