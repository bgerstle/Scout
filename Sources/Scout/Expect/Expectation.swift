//
//  Expectation.swift
//  Scout
//
//  Created by Brian Gerstle on 6/20/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation


/// Return a single value N times.
///
/// - Parameters:
///   - value: The value to return.
///   - times: How many times it should be returned.
/// - Returns: An expectation which returns the value the specified number of times.
public func `return`(_ value: Any?, times: UInt = 1) -> Expectation {
    return ConsumableExpectation(value: { value }, count: times)
}

// Alias for `return` if people don't want to use backticks.
let returnValue = `return`

/// Return the same value every time.
///
/// Useful for "stubbing" values in cases where you don't care how many times it's called.
/// Will not trigger failures on `verify`.
///
/// - Parameter value: The value to return
/// - Returns: An expectation that always returns the specified value.
public func alwaysReturn(_ value: Any?) -> Expectation {
    return PersistentExpectation(value: { value })
}

/// Get a return value from a closure N times.
///
/// - Parameters:
///   - times: Number of times the closure is expected to be called.
///   - getter: The closure which returns a value.
/// - Returns: An expectation which calls the getter.
public func get(times: UInt = 1,
                _ getter: @escaping () -> Any?) -> Expectation {
    return ConsumableExpectation(value: getter, count: times)
}

// Interface for all expectations of a mock.
public protocol Expectation: class {
    func hasNext() -> Bool
    func nextValue() -> Any?
    func shouldVerify() -> Bool
}

extension Expectation {
    func shouldVerify() -> Bool {
        return true
    }
}

// Expectation that's removed after it's used
class ConsumableExpectation : Expectation {
    var valuesRemaining: UInt
    let value: () -> Any?

    init(value: @escaping () -> Any?, count: UInt = 1) {
        self.value = value
        assert(count > 0)
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

extension ConsumableExpectation : CustomStringConvertible {
    var description: String {
        return "Return a value \(valuesRemaining) \(valuesRemaining == 1 ? "time": "times")"
    }
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

    func shouldVerify() -> Bool {
        return false
    }
}

extension PersistentExpectation : CustomStringConvertible {
    var description: String {
        return "Return a value indefinitely"
    }
}
