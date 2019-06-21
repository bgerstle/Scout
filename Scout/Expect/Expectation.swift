//
//  Expectation.swift
//  Scout
//
//  Created by Brian Gerstle on 6/20/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

// Interface for all expectations of a mock.
protocol Expectation: class {
    func hasNext() -> Bool
    func nextValue() -> Any?
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
