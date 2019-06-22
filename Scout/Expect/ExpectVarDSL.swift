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
    public func to(_ expectation: Expectation, _ file: String = #file, _ line: UInt = #line) -> ExpectVarDSL {
        mock.append(expectation: expectation, for: member, file: file, line: line)
        return self
    }
    
    public var and: ExpectVarDSL {
        return self
    }
}

public func get(_ getter: @escaping () -> Any?) -> Expectation {
    return GetterExpectation(getter: getter)
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
