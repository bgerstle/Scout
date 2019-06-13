//
//  ExpectFuncDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/13/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

@dynamicCallable
public class ExpectFuncDSL {
    let mock: Mock
    let funcName: String

    // Declared as var because `args` are set after the recorder is returned as a
    // dynamicMemmber of ExpectDSL.
    var argMatchers: [Matcher]! = nil

    init(mock: Mock, funcName: String) {
        self.mock = mock
        self.funcName = funcName
    }

    internal func checkArgs(args: [Any?]) {
        fail(unless: args.count == self.argMatchers.count,
             "Expected \(self.argMatchers.count) arguments, but got \(args.count)")
        let mistmatchedArgsAndMatchers = zip(args, self.argMatchers).filter { (arg, matcher) in
            return !matcher.matches(arg: arg)
        }
        fail(unless: mistmatchedArgsAndMatchers.count == 0,
             "Arguments to \(funcName) didn't match: \(mistmatchedArgsAndMatchers)")
    }

    public struct FuncDSL {
        let mock: Mock
        let argRecorder: ExpectFuncDSL

        @discardableResult
        public func to(return value: Any?) -> FuncDSL {
            return to { args in
                value
            }
        }

        // TODO: use some code generator to make polyvariadic version of `andDo` which
        // constrains its type parameters to Equatable? Or, some sort of AnyEquatable
        // wrapper that allows for comparison?
        @discardableResult
        public func to(do block: @escaping ([Any?]) -> Any?) -> FuncDSL {
            mock.append(expectation: FuncExpectation { args in
                self.argRecorder.checkArgs(args: args)
                return block(args)
            }, for: argRecorder.funcName)
            return self
        }
    }

    public func dynamicallyCall(withArguments matchers: [Matcher]) -> FuncDSL {
        self.argMatchers = matchers
        return FuncDSL(mock: mock, argRecorder: self)
    }
}

public protocol Matcher {
    func matches(arg: Any?) -> Bool
}

func equalTo<T: Equatable>(_ value: T?) -> Matcher {
    return EqualityMatcher(value: value)
}

public class EqualityMatcher<T: Equatable>: Matcher, CustomStringConvertible {
    let value: T?

    init(value: T?) {
        self.value = value
    }

    public func matches(arg: Any?) -> Bool {
        return value == nil && arg == nil || (arg as? T) == value
    }

    public var description: String {
        return "Equal to \(String(describing: value))"
    }
}
