//
//  Expectation.swift
//  Scout
//
//  Created by Brian Gerstle on 6/20/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

// Interface for all expectations of a mock.
public protocol Expectation: class {
    func hasNext() -> Bool
    func nextValue() -> Any?
}

public func `return`(_ value: Any?, times: UInt = 1) -> Expectation {
    return ConsumableExpectation(value: { value }, count: times)
}

// Expectation that's removed after it's used
class ConsumableExpectation : Expectation {
    var valuesRemaining: UInt
    let value: () -> Any?

    init(value: @escaping () -> Any?, count: UInt = 1) {
        self.value = value
        self.valuesRemaining = count
    }

    func hasNext() -> Bool {
        return valuesRemaining > 0
    }

    func nextValue() -> Any? {
        valuesRemaining -= 1
        return value()
    }
}

public func `alwaysReturn`(_ value: Any?) -> Expectation {
    return PersistentExpectation(value: { value })
}

// Expectation that's never removed
class PersistentExpectation : Expectation {
    let value: () -> Any?

    init(value: @escaping () -> Any?) {
        self.value = value
    }

    func hasNext() -> Bool {
        return true
    }

    func nextValue() -> Any? {
        return value()
    }
}
