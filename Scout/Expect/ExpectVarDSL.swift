//
//  ExpectVarDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/13/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

public struct ExpectVarDSL {
    let mock: Mock
    let member: String

    @discardableResult
    public func to(return value: Any?) -> ExpectVarDSL {
        mock.append(expectation: ConsumableExpectation(value: { value }), for: member)
        return self
    }

    @discardableResult
    public func to(alwaysReturn value: Any?) -> ExpectVarDSL {
        mock.append(expectation: PersistentExpectation(value: { value }), for: member)
        return self
    }

    @discardableResult
    public func to(get getter: @autoclosure @escaping () -> Any?) -> ExpectVarDSL {
        mock.append(expectation: ConsumableExpectation(value: getter), for: member)
        return self
    }

    @discardableResult
    public func to<S: Sequence>(returnValuesFrom values: S) -> ExpectVarDSL where S.Element: Any {
        values.forEach { to(return: $0) }
        return self
    }

    public var and:  ExpectVarDSL {
        return self
    }
}

class PersistentVarValue : Expectation {
    let value: Any?

    init(value: Any?) {
        self.value = value
    }

    func hasNext() -> Bool {
        return true
    }

    func nextValue() -> Any? {
        return value
    }
}

class GetterExpectation : Expectation {
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
