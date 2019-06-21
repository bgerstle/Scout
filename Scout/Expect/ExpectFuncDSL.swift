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

public struct FuncDSL {
    let context: MockFuncContext
    let argChecker: ArgChecker

    init(context: MockFuncContext, matchers: KeyValuePairs<String, ArgMatcher>) {
        self.init(context: context, matchers: matchers.keyValuePairArray)
    }

    init(context: MockFuncContext, matchers: [KeyValuePair<String, ArgMatcher>]) {
        self.context = context
        self.argChecker = ArgChecker(context: context, argMatchers: matchers)
    }

    @discardableResult
    public func to(return value: Any?) -> FuncDSL {
        return toCall { args in
            value
        }
    }

    public func toAlways(return value: Any?) {
        toAlwaysCall { args in
            value
        }
    }

    public func toBeCalled(times: Int = 1) {
        (0..<times).forEach { _ in to { } }
    }

    @discardableResult
    public func toCall(_ block: @escaping (KeyValuePairs<String, Any?>) throws -> Any?) -> FuncDSL {
        context.mock.append(expectation: ConsumableExpectation(value: { self.argChecker.wrap(block) }),
                            for: context.funcName)
        return self
    }

    @discardableResult
    public func toAlwaysCall(_ block: @escaping (KeyValuePairs<String, Any?>) throws -> Any?) -> FuncDSL {
        context.mock.append(expectation: PersistentExpectation(value: { self.argChecker.wrap(block) }),
                            for: context.funcName)
        return self
    }

    var and: FuncDSL {
        return self
    }
}

// Using plain array of tuples instead of KeyValuePairs because the latter
// can't be instantiated directly or manipulated.
typealias KeyValuePair<K, V> = (key: K, value: V)

extension KeyValuePairs {
    var keyValuePairArray: [KeyValuePair<Key, Value>] {
        return map { $0 }
    }
}

struct ArgChecker {
    let context: MockFuncContext
    let argMatchers: [KeyValuePair<String, ArgMatcher>]

    func wrap(_ block: @escaping (KeyValuePairs<String, Any?>) throws -> Any?) -> (KeyValuePairs<String, Any?>) throws -> Any? {
        return { args in
            self.checkArgs(args: args)
            return try block(args)
        }
    }

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
