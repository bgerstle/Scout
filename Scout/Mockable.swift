//
//  Mockable.swift
//  Scout
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

protocol VarExpectation: class {
    func hasNext() -> Bool
    func nextValue() -> Any?
}

class SingleValueVarExpectation : VarExpectation {
    private var consumed: Bool = false
    let value: Any?

    init(value: Any?) {
        self.value = value
    }

    func hasNext() -> Bool {
        return !consumed
    }

    func nextValue() -> Any? {
        consumed = true
        return value
    }
}

class VarValueStack : VarExpectation {
    var values: [Any] = []

    init(values: [Any]) {
        self.values = values
    }

    func hasNext() -> Bool {
        return values.count > 0
    }

    func nextValue() -> Any? {
        return values.removeFirst()
    }
}

class PersistentVarValue : VarExpectation {
    let value: Any

    init(value: Any) {
        self.value = value
    }

    func hasNext() -> Bool {
        return true
    }

    func nextValue() -> Any? {
        return value
    }
}

class FuncExpectation: VarExpectation {
    let action: ([Any?]) -> Any?

    init(action: @escaping ([Any?]) -> Any?) {
        self.action = action
    }

    func hasNext() -> Bool {
        return false
    }

    func nextValue() -> Any? {
        return action
    }
}

class VarValueGetter : VarExpectation {
    let getter: () -> Any?

    init(getter: @escaping () -> Any?) {
        self.getter = getter
    }

    func hasNext() -> Bool {
        return true
    }

    func nextValue() -> Any? {
        return getter()
    }
}

@dynamicMemberLookup
public class Mock {
    public init() { }

    private var varExpectations: [String: [VarExpectation]] = [:]

    internal func append(expectation: VarExpectation, for member: String) {
        varExpectations[member] = varExpectations[member, default: []] + [expectation]
    }

    internal func next(expectationFor member: String) -> VarExpectation {
        guard let expectations = varExpectations[member] else {
            assertionFailure("No actions defined for member \(member)")
            fatalError()
        }
        assert(expectations.count > 0, "No more expectations defined for \(member)")
        let expectation = expectations[0]
        return expectation
    }

    // Entry point for mock classes to get/set values on the mock. See "ExpectDSL" for stubbing.
    public subscript<T>(dynamicMember member: String) -> T! {
        get {
            let expectation = next(expectationFor: member)
            let value = expectation.nextValue()
            // remove expectation if all its values have been consumed
            if !expectation.hasNext() {
                varExpectations[member]!.removeFirst()
            }
            if value == nil {
                return nil
            }
            guard let typedValue = value as? T? else {
                assertionFailure("Expected value of type \(T.self) for \(member), got \(type(of: value))")
                fatalError()
            }
            return typedValue
        }
    }
}

@dynamicMemberLookup
public struct ExpectDSL {
    let mock: Mock

    public struct MemberActionDSL {
        let mock: Mock
        let member: String

        @discardableResult
        public func toReturn(_ value: Any?) -> MemberActionDSL {
            mock.append(expectation: SingleValueVarExpectation(value: value), for: member)
            return self
        }

        @discardableResult
        public func toReturn<S: Sequence>(valuesFrom values: S) -> MemberActionDSL where S.Element: Any {
            mock.append(expectation: VarValueStack(values: Array(values)), for: member)
            return self
        }

        public var and:  MemberActionDSL {
            return self
        }
    }

    @dynamicCallable
    public class FuncArgRecorder {
        let mock: Mock
        let funcName: String
        var args: [Any?] = []

        init(mock: Mock, funcName: String) {
            self.mock = mock
            self.funcName = funcName
        }

        public struct FuncDSL {
            let mock: Mock
            let argRecorder: FuncArgRecorder

            @discardableResult
            public func andDo(_ block: @escaping ([Any?]) -> Any?) -> FuncDSL {
                // TODO: add arg matching
                mock.append(expectation: FuncExpectation(action: block), for: argRecorder.funcName)
                return self
            }
        }

        public func dynamicallyCall(withArguments args: [Any?]) -> FuncDSL {
            self.args = args
            return FuncDSL(mock: mock, argRecorder: self)
        }
    }

    public subscript(dynamicMember member: String) -> MemberActionDSL {
        get {
            return MemberActionDSL(mock: mock, member: member)
        }
    }

    public subscript(dynamicMember member: String) -> FuncArgRecorder {
        get {
            return FuncArgRecorder(mock: mock, funcName: member)
        }
    }
}

public protocol Mockable {
    var mock: Mock { get }
}

public extension Mockable {
    var expect: ExpectDSL {
        return ExpectDSL(mock: mock)
    }
}

