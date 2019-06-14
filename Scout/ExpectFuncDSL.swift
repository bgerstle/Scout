//
//  ExpectFuncDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/13/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

class FuncExpectation: Expectation {
    let action: ([Any?]) throws -> Any?

    init(action: @escaping ([Any?]) throws -> Any?) {
        self.action = action
    }

    func hasNext() -> Bool {
        return false
    }

    func nextValue() -> Any? {
        return action
    }
}

@dynamicCallable
public class ExpectFuncDSL {
    let mock: Mock
    let funcName: String

    // Declared as var because `argMatchers` are set when the dynamicCallable is called (after
    // ExpectFuncDSL is returned as a dynamicMember of ExpectDSL).
    var argMatchers: [ArgMatcher]! = nil

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
        public func toCall(_ block: @escaping ([Any?]) throws -> Any?) -> FuncDSL {
            mock.append(expectation: FuncExpectation { args in
                self.argRecorder.checkArgs(args: args)
                return try block(args)
            }, for: argRecorder.funcName)
            return self
        }
    }

    public func dynamicallyCall(withArguments matchers: [ArgMatcher]) -> FuncDSL {
        self.argMatchers = matchers
        return FuncDSL(mock: mock, argRecorder: self)
    }
}
