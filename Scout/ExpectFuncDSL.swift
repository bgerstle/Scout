//
//  ExpectFuncDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/13/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

protocol MockFuncContext {
    var mock: Mock { get }
    var funcName: String { get }
}

@dynamicCallable
public class ExpectFuncDSL : MockFuncContext {
    let mock: Mock
    let funcName: String

    // Declared as var because `argMatchers` are set when the dynamicCallable is called (after
    // ExpectFuncDSL is returned as a dynamicMember of ExpectDSL).
    var argMatchers: [ArgMatcher]! = nil

    init(mock: Mock, funcName: String) {
        self.mock = mock
        self.funcName = funcName
    }

    func dynamicallyCall(withKeywordArguments argMatchers: KeyValuePairs<String, ArgMatcher>) -> FuncDSL {
        return FuncDSL(context: self, matchers: argMatchers)
    }
}

class FuncExpectation: Expectation {
    let action: (KeyValuePairs<String, Any?>) throws -> Any?

    init(action: @escaping (KeyValuePairs<String, Any?>) throws -> Any?) {
        self.action = action
    }

    func hasNext() -> Bool {
        return false
    }

    func nextValue() -> Any? {
        return action
    }
}

public struct FuncDSL {
    let context: MockFuncContext
    let argChecker: ArgChecker

    init(context: MockFuncContext, matchers: KeyValuePairs<String, ArgMatcher>) {
        self.context = context
        self.argChecker = ArgChecker(context: context, argMatchers: matchers)
    }

    @discardableResult
    public func to(return value: Any?) -> FuncDSL {
        return toCall { args in
            value
        }
    }

    @discardableResult
    public func toBeCalled(times: Int = 1) -> FuncDSL {
        (0..<times).forEach { _ in to { } }
        return self
    }

    @discardableResult
    public func toCall(_ block: @escaping (KeyValuePairs<String, Any?>) throws -> Any?) -> FuncDSL {
        context.mock.append(expectation: FuncExpectation { args in
            self.argChecker.checkArgs(args: args)
            return try block(args)
        }, for: context.funcName)
        return self
    }
}

struct ArgChecker {
    let context: MockFuncContext
    let argMatchers: KeyValuePairs<String, ArgMatcher>

    internal func checkArgs(args: KeyValuePairs<String, Any?>) {
        fail(unless: args.count == self.argMatchers.count,
             "Expected \(self.argMatchers.count) arguments, but got \(args.count)")

        let mistmatchedArgsAndMatchers = zip(args, self.argMatchers).filter { (argPair, matcherPair) in
            return argPair.key == matcherPair.key && !matcherPair.value.matches(arg: argPair.value)
        }

        fail(unless: mistmatchedArgsAndMatchers.count == 0,
             "Arguments to \(context.funcName) didn't match: \(mistmatchedArgsAndMatchers)")
    }
}
