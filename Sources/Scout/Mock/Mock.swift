//
//  Mockable.swift
//  Scout
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

public typealias SourceLocation = (file: StaticString, line: UInt)

public class Mock {
    public init() { }

    private var memberExpectations: [String: [Expectation]] = [:]

    internal func append(expectation: Expectation, for member: String) {
        memberExpectations[member] =
            memberExpectations[member, default: []] + [expectation]
    }

    internal func next(expectationFor member: String) -> Any? {
        guard let expectations = memberExpectations[member] else {
            recordFailure("No expectations defined for \(member)")
            return nil
        }
        guard expectations.count > 0 else {
            recordFailure("No more expectations defined for \(member)")
            return nil
        }

        let expectation = expectations[0]

        let value = expectation.nextValue()

        // remove expectation if all its values have been consumed
        if !expectation.hasNext() {
            memberExpectations[member]!.removeFirst()
        }

        return value
    }

    func assertNoExpectationsRemaining(file: StaticString = #file, line: UInt = #line) -> Void {
        fail(
            unless: memberExpectations.values.allSatisfy { expectations in
                expectations.filter { $0.shouldVerify() }.count == 0
            },
            "Remaining expectations: \(String(reflecting: memberExpectations))",
            file: file,
            line: line
        )
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
