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
        mock.append(expectation: SingleValueExpectation(value: value), for: member)
        return self
    }

    @discardableResult
    public func to(alwaysReturn value: Any?) -> ExpectVarDSL {
        mock.append(expectation: PersistentVarValue(value: value), for: member)
        return self
    }

    @discardableResult
    public func to(get getter: @autoclosure @escaping () -> Any?) -> ExpectVarDSL {
        mock.append(expectation: GetterExpectation(getter: getter), for: member)
        return self
    }

    @discardableResult
    public func to<S: Sequence>(returnValuesFrom values: S) -> ExpectVarDSL where S.Element: Any {
        mock.append(expectation: MultiValueExpectation(values: Array(values)), for: member)
        return self
    }

    public var and:  ExpectVarDSL {
        return self
    }
}

class SingleValueExpectation : Expectation {
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

class MultiValueExpectation : Expectation {
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
