//
//  Mockable.swift
//  Scout
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

public class Mock {
    public init() { }

    private var memberExpectations: [String: [Expectation]] = [:]

    internal func append(expectation: Expectation, for member: String) {
        memberExpectations[member] = memberExpectations[member, default: []] + [expectation]
    }

    internal func next(expectationFor member: String) -> Any? {
        guard let expectations = memberExpectations[member] else {
            recordFailure("No actions defined for member \(member)")
            return nil
        }
        fail(unless: expectations.count > 0, "No more expectations defined for \(member)")
        let expectation = expectations[0]
        let value = expectation.nextValue()
        // remove expectation if all its values have been consumed
        if !expectation.hasNext() {
            memberExpectations[member]!.removeFirst()
        }
        return value
    }

    /*
    Returns a dynamic member proxy that can be used to access var stubs. For example:

       mock.get.foo
    */
    public var get: VarDSL {
        return VarDSL(mock: self)
    }

    /*
    Returns a dynamic member proxy that can be used to invoke function call stubs. For example:

       mock.call.bar()
    */
    public var call: CallDSL {
        return CallDSL(mock: self)
    }
}
