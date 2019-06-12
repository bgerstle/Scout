//
//  Mockable.swift
//  Scout
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

// Interface for all expectations of a mock.
protocol Expectation: class {
    func hasNext() -> Bool
    func nextValue() -> Any?
}

public class Mock {
    public init() { }

    private var varExpectations: [String: [Expectation]] = [:]

    internal func append(expectation: Expectation, for member: String) {
        varExpectations[member] = varExpectations[member, default: []] + [expectation]
    }

    internal func next(expectationFor member: String) -> Any? {
        guard let expectations = varExpectations[member] else {
            recordFailure("No actions defined for member \(member)")
            return nil
        }
        fail(unless: expectations.count > 0, "No more expectations defined for \(member)")
        let expectation = expectations[0]
        let value = expectation.nextValue()
        // remove expectation if all its values have been consumed
        if !expectation.hasNext() {
            varExpectations[member]!.removeFirst()
        }
        return value
    }
}
