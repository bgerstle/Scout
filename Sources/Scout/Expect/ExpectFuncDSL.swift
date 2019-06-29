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

    public func dynamicallyCall(withKeywordArguments argMatchers: KeyValuePairs<String, ArgMatcher>) -> FuncDSL {
        return FuncDSL(context: self, matchers: argMatchers)
    }
}

public typealias FuncExpectationBlock = (KeyValuePairs<String, Any?>) throws -> Any?

public protocol FuncExpectation {
    func hasNext() -> Bool
    func nextBlock() -> FuncExpectationBlock
    func shouldVerify() -> Bool
}

extension FuncExpectation {
    func shouldVerify() -> Bool {
        return true
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
    public func to(
        _ expectation: FuncExpectation,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> FuncDSL {
        let wrappedExpectation = ArgCheckingFuncExpectationWrapper(
            expectation: expectation,
            argChecker: argChecker,
            location: (file: file, line: line)
        )
        context.mock.append(expectation: wrappedExpectation, for: context.funcName)
        return self
    }

    @discardableResult
    public func toBeCalled(
        times: UInt = 1,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> FuncDSL {
        let noop: FuncExpectationBlock = { _ in nil }
        (0..<times).forEach { _ in to(ConsumableExpectation(value: { noop }), file, line) }
        return self
    }

    @discardableResult
    public func to(
        _ expectation: Expectation,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> FuncDSL {
        return to(ExpectationFuncWrapper(expectation: expectation), file, line)
    }

    public func toAlways(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ block: @escaping FuncExpectationBlock
    ) {
        to(AlwaysCallFuncExpectation(block: block), file, line)
    }

    @discardableResult
    public func to(
        times: Int = 1,
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ block: @escaping FuncExpectationBlock
    ) -> FuncDSL {
        return to(CallFuncExpectation(block: block, times: times), file, line)
    }

    public var and: FuncDSL {
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

    func wrap(_ block: @escaping FuncExpectationBlock, location: SourceLocation) -> FuncExpectationBlock {
        return { args in
            self.checkArgs(args: args, location: location)
            return try block(args)
        }
    }

    internal func checkArgs(args: KeyValuePairs<String, Any?>, location: SourceLocation) {
        fail(unless: args.count == self.argMatchers.count,
             "Expected \(self.argMatchers.count) arguments, but got \(args.count)",
            file: location.file,
            line: location.line)

        let mistmatchedArgsAndMatchers = zip(args, self.argMatchers).filter { (argPair, matcherPair) in
            return argPair.key == matcherPair.key && !matcherPair.value.matches(arg: argPair.value)
        }

        fail(unless: mistmatchedArgsAndMatchers.count == 0,
             "Arguments to \(context.funcName) didn't match: \(mistmatchedArgsAndMatchers)",
            file: location.file,
            line: location.line)
    }
}

class CallFuncExpectation : FuncExpectation {
    var remainingCalls: Int
    let block: FuncExpectationBlock

    init(block: @escaping FuncExpectationBlock, times: Int = 1) {
        self.block = block
        assert(times > 0)
        self.remainingCalls = times
    }

    func hasNext() -> Bool {
        return remainingCalls > 0
    }

    func nextBlock() -> FuncExpectationBlock {
        remainingCalls -= 1
        return block
    }
}

class AlwaysCallFuncExpectation : FuncExpectation {
    let block: FuncExpectationBlock

    init(block: @escaping FuncExpectationBlock) {
        self.block = block
    }

    func hasNext() -> Bool {
        return true
    }

    func nextBlock() -> FuncExpectationBlock {
        return block
    }

    func shouldVerify() -> Bool {
        return false
    }
}

class ExpectationFuncWrapper : FuncExpectation {
    let expectation: Expectation

    init(expectation: Expectation) {
        self.expectation = expectation
    }

    func nextBlock() -> FuncExpectationBlock {
        // must eagerly retrieve next value, otherwise (if it's a consumable expectation)
        // it won't be marked as consumed & removed in the Mock logic (which checks before
        // the returned block is invoked)
        let result = self.expectation.nextValue()
        return { _ in result }
    }

    func nextValue() -> Any? {
        return nextBlock()
    }

    func hasNext() -> Bool {
        return expectation.hasNext()
    }

    func shouldVerify() -> Bool {
        return expectation.shouldVerify()
    }
}

class ArgCheckingFuncExpectationWrapper : Expectation {
    let expectation: FuncExpectation
    let argChecker: ArgChecker
    let location: SourceLocation

    init(expectation: FuncExpectation, argChecker: ArgChecker, location: SourceLocation) {
        self.expectation = expectation
        self.argChecker = argChecker
        self.location = location
    }

    public func hasNext() -> Bool {
        return expectation.hasNext()
    }

    public func nextValue() -> Any? {
        return argChecker.wrap(expectation.nextBlock(), location: location)
    }

    public func shouldVerify() -> Bool {
        return expectation.shouldVerify()
    }
}