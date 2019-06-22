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

public func `return`(_ value: Any?) -> Expectation {
    return ConsumableExpectation(value: { value })
}

// Expectation that's removed after it's used
class ConsumableExpectation : Expectation {
    var consumed: Bool = false
    let value: () -> Any?

    init(value: @escaping () -> Any?) {
        self.value = value
    }

    func hasNext() -> Bool {
        return !consumed
    }

    func nextValue() -> Any? {
        consumed = true
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
